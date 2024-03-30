
-- example libraries
--
-- a library,
-- inserts `lib_name` to `lib` table
-- contains `lib_name`() procedure
--      calls init_lib to init GD[`lib_name`]
--      builds GD[`lib_name`]
--      puts GD[`lib_name`] to `func`
--
\ir libs/finan_fixed_rates.sql
\ir libs/finan_black_scholes.sql
\ir libs/finan_cashflow.sql
