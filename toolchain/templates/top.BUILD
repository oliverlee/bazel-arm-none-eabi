"""
This BUILD file marks the top-level package of the generated toolchain
repository, i.e., the targets defined here appear in the workspace as
"@arm_none_eabi//:*" for arm-none-eabi toolchains.
"""

load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
load("@toolchains_arm_gnu//toolchain:constraints.bzl", "constraints")
load("@toolchains_arm_gnu//toolchain:tools.bzl", "tools")

package(default_visibility = ["//visibility:public"])

[
    config_setting(
        name = host,
        constraint_values = constraint_values,
    )
    for host, constraint_values in constraints.host["%toolchain_prefix%"].items()
]

[
    native_binary(
        name = tool,
        src = select({
            host: "@{}_{}//:{}".format(
                "%toolchain_prefix%".replace("-", "_"),
                host,
                tool,
            )
            for host in constraints.host["%toolchain_prefix%"].keys()
        }),
        out = tool,
        target_compatible_with = select({
            host: constraint_values
            for host, constraint_values in constraints.host["%toolchain_prefix%"].items()
        } | {
            "//conditions:default": ["@platforms//:incompatible"],
        }),
    )
    for tool in tools
]
