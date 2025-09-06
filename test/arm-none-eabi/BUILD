# project/BUILD.bazel

load("@arm_none_eabi//toolchain:toolchain.bzl", "arm_none_eabi_toolchain")
load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

cc_library(
    name = "link",
    additional_linker_inputs = [
        "microbit.ld",
    ],
    linkopts = [
        "-T $(location :microbit.ld)",
    ],
)

arm_none_eabi_toolchain(
    name = "microbit_toolchain",
    copts = [
        "--target=armv6m-none-eabi",
        "-mcpu=cortex-m0",
        "-mthumb",
        "-mfloat-abi=soft",
        "-mfpu=none",
        "-fno-exceptions",
        "-fno-rtti",
    ],
    linkopts = [
        "--target=armv6m-none-eabi",
        "-mcpu=cortex-m0",
        "-mthumb",
        "-mfloat-abi=soft",
        "-mfpu=none",
        "-fno-exceptions",
        "-fno-rtti",
        "-nostartfiles",
        "-lcrt0-semihost",
        "-lsemihost",
        "-lc++",
    ],
    additional_link_libraries = [
        ":link",
    ],
    target_compatible_with = [
        "@platforms//os:none",
        "@platforms//cpu:arm",
        #"@platforms//cpu:armv7e-m",
    ],
    toolchain_files_package = "@arm_clang_20.1.0_files",
    #toolchain_files_package = "@arm_none_eabi_14.3.1_files",
    #version = "14.3.1",
)

platform(
    name = "arm_none_eabi",
    constraint_values = [
        "@platforms//cpu:arm",
        "@platforms//os:none",
    ],
)

cc_library(
    name = "arm_library",
    srcs = ["library.cpp"],
    hdrs = ["library.h"],
    copts = [
        "-mcpu=cortex-a5",
        "-mthumb",
    ],
    includes = ["includes"],
    target_compatible_with = [
        "@platforms//cpu:arm",
        "@platforms//os:none",
    ],
)

cc_binary(
    name = "app",
    srcs = ["main.cpp"],
    copts = [
        "-mcpu=cortex-a5",
        "-mthumb",
    ],
    features = ["generate_linkmap"],
    linkopts = [
        "-nostartfiles",
        "-Wl,--entry,main",
        "--specs=nano.specs",
    ],
    deps = [":arm_library"],
)

filegroup(
    name = "linkmap",
    srcs = [":app"],
    output_group = "linkmap",
)

platform_transition_filegroup(
    name = "arm_none_eabi_app",
    srcs = [":app"],
    target_platform = ":arm_none_eabi",
)

platform_transition_filegroup(
    name = "arm_none_eabi_app_map",
    srcs = [":linkmap"],
    target_platform = ":arm_none_eabi",
)

genrule(
    name = "map",
    srcs = [":arm_none_eabi_app_map"],
    outs = ["app.map"],
    cmd = "cp $< $@",
    executable = True,
    visibility = ["//visibility:public"],
)

genrule(
    name = "elf",
    srcs = [":arm_none_eabi_app"],
    outs = ["app.elf"],
    cmd = "cp $< $@",
    executable = True,
    visibility = ["//visibility:public"],
)

genrule(
    name = "hex",
    srcs = [":arm_none_eabi_app"],
    outs = ["app.hex"],
    cmd = "$(execpath @arm_none_eabi//:objcopy) -O ihex $< $@",
    tools = ["@arm_none_eabi//:objcopy"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "builds_without_warnings",
    srcs = ["builds_without_warnings.c"],
    copts = [
        "-mcpu=cortex-a5",
        "-mthumb",
        "-fdiagnostics-color",
        "-Werror",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
    ],
    linkopts = [
        "-nostartfiles",
        "-Wl,--entry,main",
        "--specs=nano.specs",
    ],
    tags = ["manual"],
)

platform_transition_filegroup(
    name = "builds_without_warnings_bin",
    srcs = [":builds_without_warnings"],
    target_platform = ":arm_none_eabi",
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "baremetal-semihosting",
    srcs = ["baremetal-semihosting.cpp"],
    tags = ["manual"],
)

platform_transition_filegroup(
    name = "baremetal-semihosting_bin",
    srcs = [":baremetal-semihosting"],
    target_platform = ":arm_none_eabi",
    visibility = ["//visibility:public"],
)
