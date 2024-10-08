"""
Builing LLVM using Spaces
"""

load("tools-llvm/config.star", "sha256", "version")

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
