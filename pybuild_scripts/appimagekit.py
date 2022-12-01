# -*- python -*-

import pybuild


class AppImageKit(pybuild.ProgramBuilder):
    name = "appimagekit"

    source_repository = "https://github.com/AppImage/AppImageKit.git"
    git_tag_regex = r"^(?P<version>\d+)$"

    apt_build_dependencies = [
        # Standard
        "git",
        "cmake",
        "make",
        "ninja-build",
        "g++",
        "autoconf",
        # Library specific
        "autotools-dev",
        "libtool",
        "wget",
        "xxd",
        "desktop-file-utils",
        "pkg-config",
        "libglib2.0-dev",
        "zlib1g-dev",
        "librsvg2-dev",
        "libcairo2-dev",
        "libfuse-dev",
    ]

    build_system = "cmake"
    configure = ""

    apt_run_dependencies = []
