-- typically called last by `lib_name`() procedure after building GD[`lib_name`]
-- stores GD[`lib_name`] to `func` cache table
--
create procedure put (
    lib_name text
)
    language plpython3u
    set search_path from current
as $$
    if '__set_fun' not in GD:
        GD['__set_fun'] = plpy.prepare("""
            insert into func (lib, id, src) values ($1, $2, $3)
            on conflict (lib, id)
            do update set
                src=$3,
                built_tz = current_timestamp
        """, ['text', 'text', 'bytea'])

    if '__cloudpickle' not in GD:
        import cloudpickle
        GD['__cloudpickle'] = cloudpickle

    if lib_name not in GD:
        return

    lib = GD[lib_name]

    # store lib to func table
    #
    cloudpickle = GD["__cloudpickle"]
    plan = GD["__set_fun"]
    for id, fn in lib.items():
        plpy.execute(plan, [
            lib_name,
            id,
            cloudpickle.dumps(fn)
        ])

$$;
