# project/BUILD.bazel

load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load(":transition.bzl", "platform_transition_cc_library")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

cc_library(
    name = "lib_",
    srcs = ["lib.c"],
    #target_compatible_with = [
    #    "@platforms//os:none",
    #],
)

#platform_transition_filegroup(
platform_transition_cc_library(
    name = "lib",
    srcs = [":lib_"],
    target_platform = "//custom/platform:cortex_m3",
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "binary",
    srcs = ["main.c"],
    linkopts = [
        #"-Wl,-entry=main",
    ],
    target_compatible_with = [
        "@platforms//os:none",
    ],
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
