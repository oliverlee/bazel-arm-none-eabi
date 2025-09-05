"""
This BUILD file marks the top of the host-specific cross-toolchain repository.
If the host needs @arm_none_eabi_linux_x86_64, this is the build file at the
top of that repository.
"""

load("@toolchains_arm_gnu//toolchain:tools.bzl", "tools")

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
                "bin/{}-{}".format(PREFIX, tool),
                "bin/{}-{}.exe".format(PREFIX, tool),
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
            ]
        ],
        allow_empty = False,
        exclude_directories = 0,
    ),
)

# Just the components to add to the library path.
filegroup(
    name = "library_path",
    srcs = glob(
        [
            p.format(PREFIX)
            for p in [
                "{}",
                "{}/lib",
                "lib/gcc/{}/*",
            ]
        ],
        allow_empty = False,
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
            "{}/**".format(PREFIX),
        ],
        allow_empty = False,
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
    name = "compiler_components",
    srcs = [":compiler_pieces"],
)
