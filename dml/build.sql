
-- to build a library by call [lib_name]() procedure
--
create procedure build (
    lib_name text default null
)
    language plpgsql
    set search_path from current
as $$
declare
    libs text[];
    t text;
begin
    if lib_name is null then
        select array_agg(id)
        into libs
        from lib;
    elsif not exists (
        select from lib
        where id = lib_name
    ) then
        raise exception 'unknown library';
    else
        libs = array[lib_name];
    end if;


    foreach t in array libs loop
        execute format('call %s()', t::regproc::text);
    end loop;
  end;
$$;