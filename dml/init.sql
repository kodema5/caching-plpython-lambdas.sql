-- adds common libraries to GD
-- prepares GD[`lib_name`] to be populated
-- typically called first by `lib_name`() procedure
--
create procedure init(
    lib_name text
)
    language plpython3u
    set search_path from current
as $$
    if '__numpy' not in GD:
        import numpy
        GD['__numpy'] = numpy

    if '__scipy' not in GD:
        import scipy
        GD['__scipy'] = scipy

    if '__sympy' not in GD:
        import sympy
        import sympy.stats
        GD['__sympy'] = sympy


    if lib_name not in GD:
        class AttrDict(dict):
            def __init__(self, *args, **kwargs):
                super(AttrDict, self).__init__(*args, **kwargs)
                self.__dict__ = self
        GD[lib_name] = AttrDict({})
$$;
