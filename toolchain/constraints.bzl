constraints = struct(
    host = {
        "arm-none-eabi": {
            "darwin_x86_64": ["@platforms//os:macos", "@platforms//cpu:x86_64"],
            "darwin_arm64": ["@platforms//os:macos", "@platforms//cpu:arm64"],
            "linux_x86_64": ["@platforms//os:linux", "@platforms//cpu:x86_64"],
            "linux_aarch64": ["@platforms//os:linux", "@platforms//cpu:arm64"],
            "windows_x86_64": ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        },
        "arm-none-linux-gnueabihf": {
            # ARM has not provided an arm linux toolchain for darwin.
            "linux_x86_64": ["@platforms//os:linux", "@platforms//cpu:x86_64"],
            "linux_aarch64": ["@platforms//os:linux", "@platforms//cpu:arm64"],
            "windows_x86_64": ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        },
        "aarch64-none-elf": {
            "darwin_x86_64": ["@platforms//os:macos", "@platforms//cpu:x86_64"],
            "darwin_arm64": ["@platforms//os:macos", "@platforms//cpu:arm64"],
            "linux_x86_64": ["@platforms//os:linux", "@platforms//cpu:x86_64"],
            "linux_aarch64": ["@platforms//os:linux", "@platforms//cpu:arm64"],
            "windows_x86_64": ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        },
        "aarch64-none-linux-gnu": {
            "linux_x86_64": ["@platforms//os:linux", "@platforms//cpu:x86_64"],
            "windows_x86_64": ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        },
    },
    target = {
        "arm-none-eabi": {
            "arm": ["@platforms//os:none", "@platforms//cpu:arm"],
            "armv6-m": ["@platforms//os:none", "@platforms//cpu:armv6-m"],
            "armv7-m": ["@platforms//os:none", "@platforms//cpu:armv7-m"],
            "armv7e-m": ["@platforms//os:none", "@platforms//cpu:armv7e-m"],
            "armv7e-mf": ["@platforms//os:none", "@platforms//cpu:armv7e-mf"],
            "armv8-m": ["@platforms//os:none", "@platforms//cpu:armv8-m"],
        },
        "arm-none-linux-gnueabihf": {
            "arm": ["@platforms//os:linux", "@platforms//cpu:arm"],
            "armv7": ["@platforms//os:linux", "@platforms//cpu:armv7"],
        },
        "aarch64-none-elf": {
            "arm": ["@platforms//os:none", "@platforms//cpu:aarch64"],
        },
        "aarch64-none-linux-gnu": {
            "aarch64": ["@platforms//os:linux", "@platforms//cpu:aarch64"],
        },
    },
)
