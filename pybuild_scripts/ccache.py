# -*- python -*-

import pybuild


class CCacheBuilder(pybuild.ProgramBuilder):
    name = "ccache"

    source_repository = "https://github.com/ccache/ccache.git"
    git_tag_regex = r"^v(?P<version>\d+\.\d+\.\d+)$"

    apt_build_dependencies = [
        # Standard
        "git",
        "cmake",
        "ninja-build",
        "g++",
        "gcc",
        # Library specific
        "zlib1g-dev",
        "libzstd-dev",
        "libhiredis-dev",
    ]

    build_system = "cmake"
    configure = [
        "-DOFFLINE=TRUE",
        "-DZSTD_FROM_INTERNET=OFF",
        "-DCMAKE_BUILD_TYPE:STRING=Release",
    ]

    apt_run_dependencies = [
        "libzstd1",
        pybuild.find_non_dev_version("libhiredis0.14"),
    ]
