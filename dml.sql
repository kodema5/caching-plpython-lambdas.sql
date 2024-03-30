-- utility functions for creating and managing lib in cache
--

-- a `lib_name`() procedure typically calls init_lib first and pub_lib last
--
\ir dml/init.sql
\ir dml/put.sql

-- dynamically calls `lib_name`() procedure
--
\ir dml/build.sql

-- hydates library from cache or build one first
--
\ir dml/get.sql

-- deletes from `lib` and `func` table and GD
--
\ir dml/delete.sql


