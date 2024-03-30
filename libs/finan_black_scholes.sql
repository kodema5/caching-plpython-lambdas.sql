-- https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model
--

insert into lib (id)
    values ('finan_black_scholes')
    on conflict do nothing;

create procedure finan_black_scholes()
    language plpython3u
    security definer
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    plpy.execute("call init('{lib}')".format(lib=lib_name))

    sym = GD["__sympy"]
    ND = sym.stats.Normal('x', 0, 1)
    pdf = sym.stats.density(ND)
    cdf = sym.stats.cdf(ND)

    S, K, r, tau, sigma = sym.symbols((
        'S', # current price
        'K', # strike/exercise price
        'r', # risk-free interest rate
        'tau', # time to maturity (T - t)
        'sigma', # standard deviation of stock
    ))

    d1 = (sym.ln(S / K) + (r + sigma**2 / 2) * tau) / (sigma * sym.sqrt(tau))
    d2 = d1 - (sigma * sym.sqrt(tau))

    lib = GD[lib_name]
    lib.finan_bls_call = sym.lambdify(
        [S,K,r,tau,sigma],
        cdf(d1) * S - cdf(d2) * K * sym.exp(-r * tau))

    lib.finan_bls_put = sym.lambdify(
        [S,K,r,tau,sigma],
        cdf(-d2) * K * sym.exp(-r * tau) - cdf(-d1) * S)

    lib.finan_bls_delta_call = sym.lambdify(
        [S,K,r,tau,sigma],
        cdf(d1))

    lib.finan_bls_delta_put = sym.lambdify(
        [S,K,r,tau,sigma],
        -cdf(-d1))

    lib.finan_bls_gamma = sym.lambdify(
        [S,K,r,tau,sigma],
        pdf(-d1) / (S * sigma * sym.sqrt(tau)))

    lib.finan_bls_rho_call = sym.lambdify (
        [S,K,r,tau,sigma],
        K * tau * sym.exp(-r * tau) * cdf(d2))

    lib.finan_bls_rho_put = sym.lambdify (
        [S,K,r,tau,sigma],
        -K * tau * sym.exp(-r * tau) * cdf(-d2))

    lib.finan_bls_theta_call = sym.lambdify (
        [S,K,r,tau,sigma],
        - (S * pdf(d1) * sigma) / (2 * sym.sqrt(tau))
        - r * K * sym.exp(-r * tau) * cdf(d2))

    lib.finan_bls_theta_put = sym.lambdify (
        [S,K,r,tau,sigma],
        - (S * pdf(d1) * sigma) / (2 * sym.sqrt(tau))
        + r * K * sym.exp(-r * tau) * cdf(-d2))

    lib.finan_bls_vega = sym.lambdify(
        [S,K,r,tau,sigma],
        S * pdf(d1) * sym.sqrt(tau))

    plpy.execute("call put('{lib}')".format(lib=lib_name))
$$;


create function finan_bls_call (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_call(s,k,r,tau,sigma)
$$;

create function finan_bls_put (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_put(s,k,r,tau,sigma)
$$;


create function finan_bls_delta_call (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_delta_call(s,k,r,tau,sigma)
$$;


create function finan_bls_delta_put (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_delta_put(s,k,r,tau,sigma)
$$;

create function finan_bls_gamma (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_gamma(s,k,r,tau,sigma)
$$;

create function finan_bls_rho_call (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_rho_call(s,k,r,tau,sigma)
$$;

create function finan_bls_rho_put (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_rho_put(s,k,r,tau,sigma)
$$;

create function finan_bls_theta_call (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_theta_call(s,k,r,tau,sigma)
$$;

create function finan_bls_theta_put (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_theta_put(s,k,r,tau,sigma)
$$;

create function finan_bls_vega (
    S double precision,
    K double precision,
    r double precision,
    tau double precision,
    sigma double precision
)
    returns double precision
    language plpython3u
    set search_path from current
as $$
    lib_name = 'finan_black_scholes'
    if lib_name not in GD: plpy.execute("call get('{lib}')".format(lib=lib_name))

    return GD[lib_name].finan_bls_vega(s,k,r,tau,sigma)
$$;

\if :{?test}
\if :test
    create function tests.test_finan_black_scholes()
        returns setof text
        language plpgsql
        set search_path from current
    as $$
    begin
        return next ok(trunc(finan_bls_call(50, 50, 0.12, 0.25, 0.3)::numeric,2) = 3.74, 'can call price');
        return next ok(trunc(finan_bls_put(50, 50, 0.12, 0.25, 0.3)::numeric,2) = 2.26, 'can put price');

        return next ok(trunc(finan_bls_delta_call(50, 50, 0.12, 0.25, 0.3)::numeric,2) = 0.60, 'can delta call');
        return next ok(trunc(finan_bls_delta_put(50, 50, 0.12, 0.25, 0.3)::numeric,2) = -0.39, 'can delta put');

        return next ok(trunc(finan_bls_gamma(50, 50, 0.12, 0.25, 0.3)::numeric,6) = 0.051218, 'can gamma');

        return next ok(trunc(finan_bls_rho_call(50, 50, 0.12, 0.25, 0.3)::numeric,2) = 6.66, 'can rho call');
        return next ok(trunc(finan_bls_rho_put(50, 50, 0.12, 0.25, 0.3)::numeric,2) = -5.46, 'can rho put');

        return next ok(trunc(finan_bls_theta_call(50, 50, 0.12, 0.25, 0.3)::numeric,2) = -8.96, 'can theta call');
        return next ok(trunc(finan_bls_theta_put(50, 50, 0.12, 0.25, 0.3)::numeric,2) = -3.14, 'can theta put');

        return next ok(trunc(finan_bls_vega(50, 50, 0.12, 0.25, 0.3)::numeric,2) = 9.60, 'can vega');
    end;
    $$;

\endif
\endif