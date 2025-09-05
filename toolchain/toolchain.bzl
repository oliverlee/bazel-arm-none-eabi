"""
This module provides functions to register an arm-none-eabi toolchain
"""

load("@local_config_platform//:constraints.bzl", "HOST_CONSTRAINTS")
load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("@toolchains_arm_gnu//toolchain:config.bzl", "cc_arm_gnu_toolchain_config")

# This file will be symlinked into generated toolchain repos so we need to
# explicitly specify @toolchains_arm_gnu for everything that is not overriden.
load("@toolchains_arm_gnu//toolchain:constraints.bzl", "constraints")
load("@toolchains_arm_gnu//toolchain:transitions.bzl", "toolchain_transition_library")
load("//:version.bzl", "default_version")

def _normalize(x):
    mapping = {
        "osx": "macos",
        "darwin": "macos",
        "aarch64": "arm64",
    }
    return mapping.get(x, default = x)

def _host_os_cpu():
    host_constraints = HOST_CONSTRAINTS
    if "os" not in host_constraints:
        host_constraints = reversed(host_constraints)

    return struct(
        os = _normalize(Label(host_constraints[0]).name),
        cpu = _normalize(Label(host_constraints[1]).name),
    )

def _basic_arm_gnu_toolchain(
        *,
        name = None,
        host_system_name = None,
        toolchain_prefix = "",
        toolchain_files_package = "",
        version = "",
        gcc_tool = "gcc",
        abi_version = "",
        target_compatible_with = [],
        exec_compatible_with = [],
        copts = [],
        cxxopts = [],
        conlyopts = [],
        linkopts = [],
        dbg_compile_flags = None,
        opt_compile_flags = None,
        opt_link_flags = None,
        additional_link_libraries = [],
        include_std = True,
        visibility = None):
    """
    Create a cc_toolchain_config, cc_toolchain, toolchain triple for a single
    host platform.
    """
    fix_linkopts = []

    # macOS on apple rejects the relative path LTO plugin
    if version == "13.2.1" and "darwin" in host_system_name:
        fix_linkopts.append("-fno-lto")

    toolchain_identifier = "{}_{}_{}".format(name, host_system_name, toolchain_prefix)

    if not toolchain_files_package:
        toolchain_files_package = "@{}//toolchain/{}".format(
            toolchain_prefix.replace("-", "_"),
            "{}_{}".format(toolchain_prefix, host_system_name).replace("-", "_"),
        )

    cc_arm_gnu_toolchain_config(
        name = "config_{}".format(name),
        gcc_version = version,
        gcc_tool = gcc_tool,
        abi_version = abi_version,
        host_system_name = host_system_name,
        toolchain_prefix = toolchain_prefix,
        toolchain_identifier = toolchain_identifier,
        toolchain_bins = "{}:compiler_components".format(toolchain_files_package),
        include_path = ["{}:include_path".format(toolchain_files_package)],
        library_path = ["{}:library_path".format(toolchain_files_package)],
        copts = copts,
        cxxopts = cxxopts,
        conlyopts = conlyopts,
        linkopts = linkopts + fix_linkopts,
        dbg_compile_flags = dbg_compile_flags,
        opt_compile_flags = opt_compile_flags,
        opt_link_flags = opt_link_flags,
        additional_link_libraries = additional_link_libraries,
        include_std = include_std,
        tags = ["manual"],
    )

    native.filegroup(
        name = "{}_all_linker_files".format(name),
        srcs = [
            "{}:linker_files".format(toolchain_files_package),
        ] + additional_link_libraries,
        tags = ["manual"],
    )

    cc_toolchain(
        name = "cc_toolchain_{}".format(name),
        all_files = "{}:compiler_pieces".format(toolchain_files_package),
        ar_files = "{}:ar_files".format(toolchain_files_package),
        compiler_files = "{}:compiler_files".format(toolchain_files_package),
        dwp_files = ":empty",
        linker_files = ":{}_all_linker_files".format(name),
        objcopy_files = "{}:objcopy".format(toolchain_files_package),
        strip_files = "{}:strip".format(toolchain_files_package),
        supports_param_files = 0,
        toolchain_config = ":config_{}".format(name),
        toolchain_identifier = toolchain_identifier,
        exec_transition_for_inputs = False,
        tags = ["manual"],
    )

    native.toolchain(
        name = name,
        exec_compatible_with = exec_compatible_with,
        target_compatible_with = target_compatible_with,
        toolchain = ":cc_toolchain_{}".format(name),
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
        visibility = visibility,
        tags = ["manual"],
    )

def _bootstrapped_arm_gnu_toolchain(
        *,
        name = None,
        additional_link_libraries = None,
        target_compatible_with = None,
        **kwargs):
    """
    Create two sets of the cc_toolchain_config, cc_toolchain, toolchain triple
    for a single host platform.

    This first one is used to bootstrap the second by compiling additional
    libraries that are always linked in (e.g. startup code).
    """
    bootstrap_toolchain = name + "_boostrap"
    bootstrap_platform = name + "_boostrap_platform"

    _basic_arm_gnu_toolchain(
        name = bootstrap_toolchain,
        additional_link_libraries = [],
        target_compatible_with = target_compatible_with + [
            "@toolchains_arm_gnu//toolchain:bootstrap",
        ],
        **kwargs
    )

    native.platform(
        name = bootstrap_platform,
        constraint_values = target_compatible_with + [
            "@toolchains_arm_gnu//toolchain:bootstrap",
        ],
    )

    transitioned_libraries = []
    for i, lib in enumerate(additional_link_libraries):
        library_name = "additional_link_library.{}.{}".format(name, i)
        toolchain_transition_library(
            name = library_name,
            src = lib,
            toolchain = bootstrap_toolchain,
            platform = bootstrap_platform,
            tags = ["manual"],
        )
        transitioned_libraries.append(":{}".format(library_name))

    _basic_arm_gnu_toolchain(
        name = name,
        additional_link_libraries = transitioned_libraries,
        target_compatible_with = target_compatible_with,
        **kwargs
    )

def _arm_gnu_toolchain_suite(
        *,
        name = None,
        toolchain_prefix = None,
        additional_link_libraries = [],
        visibility = None,
        **kwargs):
    """
    Create a toolchain for every supported host platform.
    """
    host_platform = _host_os_cpu()

    for host, exec_compatible_with in constraints.host[toolchain_prefix].items():
        toolchain_func = (
            _bootstrapped_arm_gnu_toolchain if additional_link_libraries else _basic_arm_gnu_toolchain
        )

        toolchain_func(
            name = "{}_{}".format(name, host),
            host_system_name = host,
            exec_compatible_with = exec_compatible_with,
            additional_link_libraries = additional_link_libraries,
            toolchain_prefix = toolchain_prefix,
            **kwargs
        )

        os, cpu = [Label(x).name for x in exec_compatible_with]
        if _normalize(os) == host_platform.os and _normalize(cpu) == host_platform.cpu:
            native.alias(
                name = name,
                actual = ":{}_{}".format(name, host),
                visibility = visibility,
            )

def arm_none_eabi_toolchain(
        name,
        version = default_version("arm-none-eabi"),
        **kwargs):
    """
    Create an arm-none-eabi toolchain with the given configuration.

    Args:
        name: The name of the toolchain.
        version: The version of the gcc toolchain.
        **kwargs: same as toolchains_arm_gnu
    """
    _arm_gnu_toolchain_suite(
        name = name,
        toolchain_prefix = "arm-none-eabi",
        version = version,
        abi_version = "eabi",
        **kwargs
    )

def arm_none_linux_gnueabihf_toolchain(
        name,
        version = default_version("arm-none-linux-gnueabihf"),
        linkopts = [],
        **kwargs):
    """
    Create an arm-none-linux-gnueabihf toolchain with the given configuration.

    Args:
        name: The name of the toolchain.
        version: The version of the gcc toolchain.
        linkopts: Additional linker options.
        **kwargs: Additional keyword arguments.
    """
    _arm_gnu_toolchain_suite(
        name = name,
        toolchain_prefix = "arm-none-linux-gnueabihf",
        version = version,
        abi_version = "gnueabihf",
        linkopts = ["-lc", "-lstdc++"] + linkopts,
        include_std = True,
        **kwargs
    )

def aarch64_none_elf_toolchain(
        name,
        version = default_version("aarch64-none-elf"),
        **kwargs):
    """
    Create a toolchain with the given configuration.

    Args:
        name: The name of the toolchain.
        version: The version of the gcc toolchain.
        **kwargs: same as toolchains_arm_gnu
    """
    _arm_gnu_toolchain_suite(
        name = name,
        toolchain_prefix = "aarch64-none-elf",
        version = version,
        abi_version = "elf",
        **kwargs
    )

def aarch64_none_linux_gnu_toolchain(
        name,
        version = default_version("aarch64-none-linux-gnu"),
        linkopts = [],
        **kwargs):
    """
    Create an aarch64-none-linux-gnu toolchain with the given configuration.

    Args:
        name: The name of the toolchain.
        version: The version of the gcc toolchain.
        linkopts: Additional linker options.
        **kwargs: Additional keyword arguments.
    """
    _arm_gnu_toolchain_suite(
        name = name,
        toolchain_prefix = "aarch64-none-linux-gnu",
        version = version,
        abi_version = "gnu",
        linkopts = ["-lc", "-lstdc++"] + linkopts,
        include_std = True,
        **kwargs
    )

# defines all toolchain macros, allowing access by toolchain-prefix
toolchain = {
    "aarch64-none-linux-gnu": aarch64_none_linux_gnu_toolchain,
    "aarch64-none-elf": aarch64_none_elf_toolchain,
    "arm-none-linux-gnueabihf": arm_none_linux_gnueabihf_toolchain,
    "arm-none-eabi": arm_none_eabi_toolchain,
}
