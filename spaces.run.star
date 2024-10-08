"""
Builing LLVM using Spaces
"""

load("tools/sysroot-gh/publish.star", "add_publish_archive")
load("tools-llvm/config.star", "version")

workspace = info.get_absolute_path_to_workspace()

run.add_exec(
    rule = {"name": "configure"},
    exec = {
        "command": "cmake",
        "args": [
            "-GNinja",
            "-Bbuild/llvm",
            "-Sllvm-project/llvm",
            "-DCMAKE_INSTALL_PREFIX={}/build/install/llvm".format(workspace),
            "-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lld",
            "-DCMAKE_BUILD_TYPE=MinSizeRel",
        ],
    },
)

run.add_exec(
    rule = {"name": "build", "deps": ["configure"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
        ],
    },
)

run.add_exec(
    rule = {"name": "test", "deps": ["build"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
            "check-all",
        ],
    },
)

run.add_exec(
    rule = {"name": "install", "deps": ["test"] },
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
            "install",
        ],
    },
)

add_publish_archive(
    name = "llvm",
    input = "build/install/llvm",
    version = version,
    deploy_repo = "https://github.com/work-spaces/tools-llvm",
    deps = ["install"]
)
