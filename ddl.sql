

-- list of available libary
-- call [lib.id]() will be constructor of library
-- D[lib.id] will be loaded lambdas to be called
--
create table lib (
    id text primary key,

    added_tz timestamp with time zone
        default current_timestamp
);


-- cached function using cloudpickle
--
create table func (
    -- library and function name
    lib text not null
        references lib(id)
        on delete cascade,
    id text not null,
    primary key (lib, id),

    -- cached lambda
    src bytea,

    -- cache data
    built_tz timestamp with time zone
        default current_timestamp
);
