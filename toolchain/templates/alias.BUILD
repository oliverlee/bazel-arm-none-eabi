"""
This BUILD file is used to alias host toolchains in the generated repo, allowing
users to register a custom toolchain without having to import the host repo
"""

load("@toolchains_arm_gnu//toolchain:tools.bzl", "tools")

[
    alias(
        name = name,
        actual = "@{repo}//:{name}".format(
            name = name,
            repo = "%host_archive%",
        ),
        visibility = ["//visibility:public"],
    )
    for name in tools + [
        "include_path",
        "library_path",
        "compiler_pieces",
        "compiler_files",
        "ar_files",
        "linker_files",
        "binaries",
    ]
]
