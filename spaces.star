"""
Builing LLVM using Spaces
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
    rule = {"name": "tools/sysroot-gh"},
    repo = {
        "url": "https://github.com/work-spaces/sysroot-gh",
        "rev": "v2",
        "checkout": "Revision",
    },
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

workspace = info.get_absolute_path_to_workspace()

run.add_exec(
    rule = {"name": "configure-llvm"},
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
    rule = {"name": "build-llvm", "deps": ["configure-llvm"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
        ],
    },
)

run.add_exec(
    rule = {"name": "test-llvm", "deps": ["build-llvm"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
            "check-all",
        ],
    },
)

run.add_exec(
    rule = {"name": "install-llvm", "deps": ["test-llvm"] },
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
            "install",
        ],
    },
)

platform = info.platform_name()

archive_info = {
    "input": "build/install/llvm",
    "name": "llvm",
    "version": version,
    "driver": "tar.xz",
    "platform": platform,
}

archive_output = info.get_path_to_build_archive(rule_name = "archive-llvm", archive = archive_info)

run.add_archive(
    rule = {"name": "archive-llvm", "deps": ["install-llvm"]},
    archive = archive_info,
)

deploy_repo = "https://github.com/work-spaces/tools-llvm"
repo_arg = "--repo={}".format(deploy_repo)
archive_name = "llvm-v{}".format(version)

run.add_exec(
    rule = {"name": "check_release", "inputs": [archive_output]},
    exec = {
        "command": "gh",
        "args": [
            "release",
            "view",
            archive_name,
            repo_arg,
        ],
        "expect": "Failure",
    },
)

run.add_exec(
    rule = {"name": "upload", "deps": ["check_release"], "inputs": [archive_output]},
    exec = {
        "command": "gh",
        "args": [
            "release",
            "upload",
            archive_name,
            archive_output,
            repo_arg,
        ],
    },
)

run.add_exec(
    rule = {"name": "release", "deps": ["upload"]},
    exec = {
        "command": "gh",
        "working_directory": "tools-llvm",
        "args": [
            "release",
            "create",
            archive_name,
            "--generate-notes",
            repo_arg,
        ],
    },
)
