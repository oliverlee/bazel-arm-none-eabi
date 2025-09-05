"""
This BUILD file defines the toolchain targets for bzlmod consumers. It is
rendered into the //toolchain package of the generated toolchain repository.
For example, "@arm_none_eabi//toolchain:*"
"""

package(default_visibility = ["//visibility:public"])

load(
    "@toolchains_arm_gnu//toolchain:toolchain.bzl",
    "toolchain",
)
load(
    "@toolchains_arm_gnu//toolchain:constraints.bzl",
    "constraints",
)

[
    toolchain["%toolchain_prefix%"](
        name = name,
        version = "%version%",
        target_compatible_with = target_compatible_with,
    )
    for name, target_compatible_with in constraints.target['%toolchain_prefix%'].items()
]
