SLICE_LOC = {
    'TIF012': 'libtiff/tif_dirwrite.c:1625'
}


SLICE_TARGETS = {
    'libtiff-tiffcp': {
        'frontend':'clang',
        'entry_point':'main',
        'bugs': ['TIF012']
    },
    # 'swftophp-4.7.1': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2017-7578']
    # },
    # 'swftophp-4.8': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2018-7868', '2018-8807', '2018-8962', '2018-11095', '2018-11225','2018-11226', '2018-20427', '2019-12982', '2020-6628']
    # },
    # 'swftophp-4.8.1': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2019-9114']
    # },
    # 'lrzip-ed51e14': {
    #     'frontend':'clang',
    #     'entry_point':'main',
    #     'bugs': ['2018-11496']
    # },
    # 'lrzip-9de7ccb': {
    #     'frontend':'clang',
    #     'entry_point':'main',
    #     'bugs': ['2017-8846']
    # },
    # 'objdump': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2017-8392', '2017-8396', '2017-8397', '2017-8398']
    # },
    # 'objcopy': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2017-8393', '2017-8394', '2017-8395']
    # },
    # 'objdump-2.31.1': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2018-17360']
    # },
    # 'nm': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2017-14940']
    # },
    # 'readelf': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2017-16828']
    # },
    # 'strip': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2017-7303']
    # },
    # 'cxxfilt': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': [
    #         '2016-4487', '2016-4489', '2016-4490', '2016-4491', '2016-4492',
    #         '2016-6131'
    #     ]
    # },
    # 'xmllint': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2017-5969', '2017-9047', '2017-9048',]
    # },
    # 'cjpeg-1.5.90': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2018-14498']
    # },
    # 'cjpeg-2.0.4': {
    #     'frontend':'cil',
    #     'entry_point':'main',
    #     'bugs': ['2020-13790']
    # },
}


def generate_slicing_worklist(benchmark):
    if benchmark == "all":
        worklist = list(SLICE_TARGETS.keys())
    elif benchmark in SLICE_TARGETS:
        worklist = [benchmark]
    else:
        print("Unsupported benchmark: %s" % benchmark)
        exit(1)
    return worklist