-- refs: https://en.wikipedia.org/wiki/Time_value_of_money

insert into lib (id)
    values ('finan_fixed_rates')
    on conflict do nothing;


create procedure finan_fixed_rates()
    language plpython3u
    security definer
    set search_path from current
as $$
    lib_name = 'finan_fixed_rates'
    plpy.execute("call init('{lib}')".format(lib=lib_name))

    # build equation
    #
    sym = GD["__sympy"]
    pmt, pv, fv, due, rate, nper = sym.symbols('fv, pmt, pv, due, rate, nper')
    # equation to solve
    e = sym.Eq (
        fv # future value
        + pv * (1 + rate)**nper # is compounded present value
        + pmt * (1 + rate * due)/rate * ((1 + rate)**nper - 1) # and periodic payments
        , 0
    )

    # store functions in GD
    #
    lib = GD[lib_name]
    lib.finan_fv = sym.lambdify(
        [rate,nper,pmt,pv,due],
        sym.solve(e,fv))

    lib.finan_nper = sym.lambdify(
        [rate,pmt,pv,fv,due],
        sym.solve(e,nper))

    lib.finan_pmt = sym.lambdify(
        [rate,nper,pv,fv,due],
        sym.solve(e,pmt))

    lib.finan_pv = sym.lambdify(
        [rate,nper,pmt,fv,due],
        sym.solve(e,pv))

    lib.finan_rate = lambda x0, guess=0.1: sym.nsolve(
        sym.Subs(e, (nper, pmt, pv, fv, due), x0).doit(),
        rate,
        guess)

    plpy.execute("call put('{lib}')".format(lib=lib_name))
$$;

create function finan_fv (
      rate double precision,
      nper double precision,
      pmt double precision default 0,
      pv double precision default 0,
      due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_fixed_rates'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_fv(rate, nper, pmt, pv, due)[0]
$$;


create or replace function finan_nper (
    rate double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_fixed_rates'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_nper(rate, pmt, pv, fv, due)[0]
$$;

create or replace function finan_pmt(
    rate double precision,
    nper double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_fixed_rates'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_pmt(rate, nper, pv, fv, due)[0]
$$;


create or replace function finan_pv(
    rate double precision,
    nper double precision,
    pmt double precision,
    fv double precision default 0,
    due int default 0 -- end: 0, begin: 1
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_fixed_rates'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_pv(rate, nper, pmt, fv, due)[0]
$$;

create or replace function finan_rate (
    nper double precision,
    pmt double precision,
    pv double precision,
    fv double precision default 0,
    due int default 0, -- end: 0, begin: 1
    guess double precision default 0.1
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_fixed_rates'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_rate((nper, pmt, pv, fv, due))
$$;


\if :{?test}
\if :test
    create or replace function tests.test_finan_fixed_rate()
        returns setof text
        language plpgsql
        set search_path from current
    as $$
    declare
        a numeric;
    begin
        a = finan_fv(0.1/4, 4*4, -2000, 0, 1);
        return next ok(trunc(a) = 39729, 'calc future-value');

        a = finan_nper(0.045/12, -100, 5000);
        return next ok(trunc(a) = 55, 'calc number of periods');

        a = finan_pmt(0.045/12, 5*12, 5000);
        return next ok(trunc(a) = -93, 'calc periodic payment');

        a = finan_pv(0.045/12, 5*12, -93.22);
        return next ok(trunc(a) = 5000, 'calc present-value');

        a = finan_rate(5 * 12.0, -93.22, 5000) * 12 * 100;
        return next ok(trunc(a,2) = 4.50, 'calc rate');

    end;
    $$;
\endif
\endif

