-- deletes a lib_name from `lib`
--      the on-delete cascade will cleans up `func` table too
-- deletes a lib_name from `GD`
--
create procedure delete(
    lib_name text
)
    language plpython3u
    set search_path from current
as $$
    if '__delete_lib' not in GD:
        GD['__delete_lib'] = plpy.prepare("""
            select * from func where lib=$1
        """, ['text'])

    plpy.execute(GD['__build_lib'], [lib_name])
    del GD[lib_name]
$$;
