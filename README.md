# caching-plpyhton-lambdas.sql

importing modules in `plpython3u` for each function call can be expensive; to
cache `cloud-pickled` lambdas and to rehydrate them as needed

- `ddl` contains `lib` and `func` tables to cache picked data
- `dml` contains functions to init, hydrate `lib`
- `libs` contains few examples based on `sympy`, `numpy` and `scipy`

build cache

    web=# call build();

check cache

    web=# select lib, id, pg_size_pretty(length(src)::bigint)
    web-# from func
    web-# order by lib, id;
            lib         |          id          | pg_size_pretty
    ---------------------+----------------------+----------------
    finan_black_scholes | finan_bls_call       | 1965 bytes
    finan_black_scholes | finan_bls_delta_call | 1178 bytes
    finan_black_scholes | finan_bls_delta_put  | 1178 bytes
    finan_black_scholes | finan_bls_gamma      | 1273 bytes
    finan_black_scholes | finan_bls_put        | 1950 bytes
    finan_black_scholes | finan_bls_rho_call   | 1419 bytes
    finan_black_scholes | finan_bls_rho_put    | 1418 bytes
    finan_black_scholes | finan_bls_theta_call | 2172 bytes
    finan_black_scholes | finan_bls_theta_put  | 2155 bytes
    finan_black_scholes | finan_bls_vega       | 1265 bytes
    finan_cashflow      | finan_irr            | 1982 bytes
    finan_cashflow      | finan_mirr           | 1910 bytes
    finan_cashflow      | finan_npv            | 994 bytes
    finan_fixed_rates   | finan_fv             | 1027 bytes
    finan_fixed_rates   | finan_nper           | 1062 bytes
    finan_fixed_rates   | finan_pmt            | 1011 bytes
    finan_fixed_rates   | finan_pv             | 1039 bytes
    finan_fixed_rates   | finan_rate           | 1354 bytes
    (18 rows)

use lambdas

    web=# select finan_fv(0.1/4, 4*4, -2000, 0, 1);
        finan_fv
    ------------------
    39729.4608941661
    (1 row)
