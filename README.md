# pickled-lambdas-cache.sql
importing `plpython3u` modules in each function call can be expensive: to cache `cloud-pickled` lambdas and to rehydrate them as needed

- `ddl` contains `lib` and `func` tables to cache picked data
- `dml` contains functions to init, hydrate `lib`
- `libs` contains few examples based on `sympy`, `numpy` and `scipy`
