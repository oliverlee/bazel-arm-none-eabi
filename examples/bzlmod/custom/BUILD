# project/BUILD.bazel

load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

cc_library(
    name = "stubs",
    srcs = ["stubs.c"],
    target_compatible_with = [
        "@toolchains_arm_gnu//toolchain:bootstrap",
    ],
    visibility = ["//visibility:public"],
    alwayslink = True,
)

cc_binary(
    name = "binary",
    srcs = ["main.c"],
)

platform_transition_filegroup(
    name = "cortex_m3_elf",
    srcs = [":binary"],
    target_platform = "//custom/platform:cortex_m3",
    visibility = ["//visibility:public"],
)

platform_transition_filegroup(
    name = "cortex_m4_elf",
    srcs = [":binary"],
    target_platform = "//custom/platform:cortex_m4",
    visibility = ["//visibility:public"],
)
