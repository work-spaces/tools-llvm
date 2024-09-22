"""

"""

checkout.update_env(
    rule = {"name": "update_env"},
    env = {
        "paths": ["/usr/bin", "/bin"],
        "vars": {
            "PS1": '"(spaces) $PS1"',
        },
    },
)

checkout.add_repo(
    rule = {"name": "tools/sysroot-ninja"},
    repo = {"url": "https://github.com/work-spaces/sysroot-ninja", "rev": "v1", "checkout": "Revision"},
)

checkout.add_repo(
    rule = {"name": "tools/sysroot-cmake"},
    repo = {
        "url": "https://github.com/work-spaces/sysroot-cmake",
        "rev": "v3",
        "checkout": "Revision",
    },
)

version = "17.0.6"
sha256 = "27b5c7c745ead7e9147c78471b9053d4f6fc3bed94baf45f4e8295439f564bb8"

checkout.add_archive(
    rule = {"name": "llvm-project"},
    archive = {
        "url": "https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-{}.zip".format(version),
        "sha256": sha256,
        "link": "Hard",
        "strip_prefix": "llvm-project-llvmorg-{}".format(version),
        "add_prefix": "llvm-project",
    },
)

workspace = info.absolute_workspace_path()

run.add_exec(
    rule = {"name": "configure-llvm"},
    exec = {
        "command": "cmake",
        "args": [
            "-GNinja",
            "-Bbuild/llvm",
            "-Sllvm-project/llvm",
            "-DCMAKE_INSTALL_PREFIX={}/build/install".format(workspace),
            "-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lld",
            "-DCMAKE_BUILD_TYPE=MinSizeRel",
        ],
    },
)

run.add_exec(
    rule = {"name": "build-llvm", "deps": ["configure-llvm"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
        ],
    },
)

run.add_exec(
    rule = {"name": "install-llvm", "deps": ["build-llvm"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
            "install"
        ],
    },
)

platform = info.platform_name()

run.add_archive(
    rule = {"name": "acrhive-llvm", "deps": ["install-llvm"]},
    archive = {
        "input": "build/install",
        "name": "llvm",
        "version": version,
        "driver": "tar.xz",
        "platform": platform,
    },
)
