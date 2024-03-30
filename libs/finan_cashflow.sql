insert into lib (id)
    values ('finan_cashflow')
    on conflict do nothing;

create procedure finan_cashflow()
    language plpython3u
    security definer
    set search_path from current
as $$
    lib_name = 'finan_cashflow'
    plpy.execute("call init('{lib}')".format(lib=lib_name))

    num = GD["__numpy"]
    sci = GD["__scipy"]

    lib = GD[lib_name]
    # net present value over rate r and cashflow cs
    def npv (r, cs):
        if r < -1.0:
            return float('inf')
        return sum([
            c / (1 + r)**i
            for i, c
            in enumerate(cs)
        ])

    lib.finan_npv = npv

    # r as such npv(r,cs) = 0
    def irr (cs):
        try:
            return sci.optimize.newton(
                lambda r: npv(r, cs),
                0.0) # x0
        except RuntimeError:
            return sci.optimize.brentq(
                lambda r: npv(r, cs),
                -1.0, # xa
                1e10) # xb

    lib.finan_irr = irr

    # modified rate of return over cashflow cs, rate r,
    # and reinvestment rate
    def mirr(cs, r, rr):
        arr = num.asarray(cs)
        n = arr.size
        pos = arr > 0
        neg = arr < 0
        if not (pos.any() and neg.any()):
            return float('nan')
        a = num.abs(npv(rr, arr * pos))
        b = num.abs(npv(r, arr * neg))
        return (a/b)**(1/(n-1)) * (1 + rr) - 1

    lib.finan_mirr = mirr

    plpy.execute("call put('{lib}')".format(lib=lib_name))
$$;


create function finan_irr (
    cashflow double precision[]
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_cashflow'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_irr(cashflow)
$$;


create function finan_mirr(
    cashflow double precision[],
    rate double precision,     -- rate on cashflow
    reinvest_rate double precision -- rate on cashflow reinvestment
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_cashflow'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_mirr(cashflow, rate, reinvest_rate)
$$;

\if :{?test}
\if :test

    create function tests.test_finan_cashflow()
        returns setof text
        language plpgsql
        set search_path from current
    as $$
    begin
        return next ok(
            trunc(finan_irr(array[-10000,3000,4200,6800]::double precision[])::numeric,5) = 0.16340,
            'calc internal rate of returns');

        return next ok(trunc(finan_mirr(
            array[-10000,3000,4200,6800]::double precision[], 0.1, 0.12) * 100) = 15,
            'calc modified internal rate of return');

    end;
    $$;
\endif
\endif

