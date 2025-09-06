tools = [
    "as", # clang
    "ar",
#    "c++", # clang
#    "cpp", # clang
    "g++", # clang
    "gcc", # clang
    "gcov",
    "gdb", # ??
    "ld",  # lld
    "nm",
    "objcopy",
    "objdump",
    "readelf",
    "strip",
    "size",
]

def clang_tool(tool):
    if tool in [
        "as",
        "c++",
        "cpp",
        "g++",
        "gcc",
    ]:
        return "clang"

    if tool == "ld":
        return "lld"

    if tool == "gcov":
        return "llvm-cov"

    return "llvm-" + tool
