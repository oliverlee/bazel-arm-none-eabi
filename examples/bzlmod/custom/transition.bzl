def _platform_transition_impl(settings, attr):
    return {
        "//command_line_option:platforms": [attr.target_platform],
    }

platform_transition = transition(
    implementation = _platform_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:platforms"],
)

def _platform_transition_cc_library_impl(ctx):
    # The actual cc_library target after transition
    src = ctx.attr.srcs[0]

    # Forward the providers from the transitioned cc_library
    return [
        src[CcInfo],
        src[DefaultInfo],
        # Add any other providers you need
    ]

platform_transition_cc_library = rule(
    implementation = _platform_transition_cc_library_impl,
    attrs = {
        "srcs": attr.label_list(
            cfg = platform_transition,
            providers = [CcInfo],
        ),
        "target_platform": attr.string(
            mandatory = True,
            doc = "The platform to transition to",
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
    },
)
