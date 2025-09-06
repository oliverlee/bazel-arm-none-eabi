"""
This BUILD file marks the top of the host-specific cross-toolchain repository.
If the host needs @arm_none_eabi_linux_x86_64, this is the build file at the
top of that repository.
"""

load("@toolchains_arm_gnu//toolchain:tools.bzl", "clang_tool", "tools")

package(default_visibility = ["//visibility:public"])

PREFIX = "%toolchain_prefix%"

# export the executable files to make them available for direct use.
exports_files(
    glob(
        ["**"],
        exclude_directories = 0,
    ),
)

[
    filegroup(
        name = tool,
        srcs = glob(
            [
                # gcc binaries
                "bin/{}-{}".format(PREFIX, tool),
                "bin/{}-{}.exe".format(PREFIX, tool),
                # clang binaries
                "bin/{}".format(clang_tool(tool)),
            ],
            allow_empty = True,
        ),
    )
    for tool in tools
]

filegroup(
    name = "include_path",
    srcs = glob(
        [
            p.format(prefix = PREFIX)
            for p in [
                # '*' is used to match the GCC version without needing to specify it
                "{prefix}/include",
                "{prefix}/include/c++/*",
                "{prefix}/include/c++/*/{prefix}",
                "lib/gcc/{prefix}/*/include",
                "lib/gcc/{prefix}/*/include-fixed",
                #
                "include",
                "lib/clang/*/include",
                "lib/clang-runtimes/{prefix}/*/include",
            ]
        ],
        #allow_empty = False,
        allow_empty = True,
        exclude_directories = 0,
    ),
)

# Just the components to add to the library path.
filegroup(
    name = "library_path",
    srcs = glob(
        [
            p.format(prefix = PREFIX)
            for p in [
                "{prefix}",
                "{prefix}/lib",
                "lib/gcc/{prefix}/*",
                "lib/clang-runtimes/{prefix}/*/lib",
            ]
        ],
        #allow_empty = False,
        allow_empty = True,
        exclude_directories = 0,
    ),
)

# libraries, headers and executables.
filegroup(
    name = "compiler_pieces",
    srcs = glob(
        [
            "bin/**",
            "lib/**",
            "libexec/**",
            "{prefix}/**".format(prefix = PREFIX),
        ],
        #allow_empty = False,
        allow_empty = True,
    ),
)

# files for executing compiler.
filegroup(
    name = "compiler_files",
    srcs = [":compiler_pieces"],
)

filegroup(
    name = "ar_files",
    srcs = [":compiler_pieces"],
)

filegroup(
    name = "linker_files",
    srcs = [":compiler_pieces"],
)

# collection of executables.
filegroup(
    name = "binaries",
    srcs = glob(
        [
            "bin/*",
        ],
        allow_empty = False,
    ),
)
