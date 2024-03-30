-- hydrate a lib_name
-- if `lib_name` is yet in `func` cache
--   `lib_name`() will be called to build-cache and load to GD
-- else
--   GD will be populated from `func` cache
--
create procedure get(
    lib_name text
)
    language plpython3u
    set search_path from current
as $$
    # update GD
    #
    if '__pickle' not in GD:
        import pickle
        GD['__pickle'] = pickle

    if '__get_lib' not in GD:
        GD['__get_lib'] = plpy.prepare("""
            select * from func where lib=$1
        """, ['text'])

    if '__has_lib' not in GD:
        GD['__has_lib'] = plpy.prepare("""
            select count(1) as count from func where lib=$1
        """, ['text'])

    if '__build_lib' not in GD:
        GD['__build_lib'] = plpy.prepare("""
            call build($1)
        """, ['text'])

    if lib_name not in GD:
        class AttrDict(dict):
            def __init__(self, *args, **kwargs):
                super(AttrDict, self).__init__(*args, **kwargs)
                self.__dict__ = self
        GD[lib_name] = AttrDict({})

    # build lib/fun if none in cache
    #
    if plpy.execute(GD["__has_lib"], [lib_name])[0]['count'] == 0:
        plpy.execute(GD['__build_lib'], [lib_name])
        return

    # retrieve and build GD from cache
    #
    pickle = GD["__pickle"]
    lib = GD[lib_name]
    for r in plpy.cursor(GD["__get_lib"], [lib_name]):
        id = r['id']
        lib[id] = pickle.loads(r['src'])
$$;
