"""Module extension for toolchains"""

load(
    "@toolchains_arm_gnu//:deps.bzl",
    "aarch64_none_elf_deps",
    "aarch64_none_linux_gnu_deps",
    "arm_none_eabi_deps",
    "arm_none_linux_gnueabihf_deps",
)
load("@toolchains_arm_gnu//:version.bzl", "latest_version", "min_version")

_common_attrs = {
    "target_compatible_with": attr.string_list(),
    "copts": attr.string_list(),
    "linkopts": attr.string_list(),
}

def _version_attr(toolchain):
    return {"version": attr.string(default = latest_version(toolchain))}

def _toolchain_repo_impl(rctx):
    name = rctx.name.rsplit("+", 1)[-1].rsplit("~", 1)[-1]

    rctx.file(
        "BUILD.bazel",
        content = """
load("@arm_none_eabi//toolchain:toolchain.bzl", "arm_none_eabi_toolchain")

arm_none_eabi_toolchain(
    name = {name},
    copts = {copts},
    target_compatible_with = {target_compatible_with},
    linkopts = {linkopts},
)
""".format(
    name = "\"{}\"".format(name),
    **{
        key: getattr(rctx.attr, key)
        for key in _common_attrs
    },
),
        executable = False,
    )

_toolchain_repo = repository_rule(
    implementation = _toolchain_repo_impl,
    attrs = _common_attrs,
)

def _module_toolchain(tag, toolchain, deps):
    """Return a module toolchain."""
    return struct(
        tag = tag,
        toolchain = toolchain,
        deps = deps,
    )

def _arm_toolchain_impl(ctx):
    """Implement the module extension."""

    available_toolchains = [
        _module_toolchain(
            tag = lambda mod: mod.tags.arm_none_eabi,
            toolchain = lambda mod: mod.tags.arm_none_eabi_toolchain,
            deps = arm_none_eabi_deps,
        ),
        #_module_toolchain(
        #    tag = lambda mod: mod.tags.arm_none_linux_gnueabihf,
        #    toolchain = lambda mod: mod.tags.arm_none_linux_gnueabihf_toolchain,
        #    deps = arm_none_linux_gnueabihf_deps,
        #),
        #_module_toolchain(
        #    tag = lambda mod: mod.tags.aarch64_none_elf,
        #    toolchain = lambda mod: mod.tags.aarch64_none_elf_toolchain,
        #    deps = aarch64_none_elf_deps,
        #),
        #_module_toolchain(
        #    tag = lambda mod: mod.tags.aarch64_none_linux_gnu,
        #    toolchain = lambda mod: mod.tags.aarch64_none_linux_gnu_toolchain,
        #    deps = aarch64_none_linux_gnu_deps,
        #),
    ]

    for mod in ctx.modules:
        for toolchain in mod.tags.arm_none_eabi_toolchain:
            attrs = {
                key: getattr(toolchain, key)
                for key in _common_attrs.keys() + ["name"]
            }
            _toolchain_repo(**attrs)

    for toolchain in available_toolchains:
        versions = [attr.version for mod in ctx.modules for attr in toolchain.tag(mod)]
        versions += [attr.version for mod in ctx.modules for attr in toolchain.toolchain(mod)]
        selected = min_version(versions)
        if selected:
            toolchain.deps(version = selected)

arm_toolchain = module_extension(
    implementation = _arm_toolchain_impl,
    tag_classes = {
        "arm_none_eabi": tag_class(attrs = _version_attr("arm-none-eabi")),
        "arm_none_eabi_toolchain": tag_class(
            attrs = _common_attrs | _version_attr("arm-none-eabi") | {"name": attr.string()},
        ),
        #"arm_none_linux_gnueabihf": tag_class(attrs = {
        #    "version": attr.string(default = latest_version("arm-none-linux-gnueabihf")),
        #}),
        #"aarch64_none_elf": tag_class(attrs = {
        #    "version": attr.string(default = latest_version("aarch64-none-elf")),
        #}),
        #"aarch64_none_linux_gnu": tag_class(attrs = {
        #    "version": attr.string(default = latest_version("aarch64-none-linux-gnu")),
        #}),
    },
)
