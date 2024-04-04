# -*- python -*-

import pybuild


class MoldBuilder(pybuild.ProgramBuilder):
    name = "mold"

    source_repository = "https://github.com/rui314/mold.git"
    git_tag_regex = r"^v(?P<version>\d+\.\d+\.\d+)$"

    apt_build_dependencies = [
        # Standard
        "git",
        "cmake",
        "ninja-build",
        "g++",
        "gcc",
        # Library specific
        "g++-10",
        "file",
        "zlib1g-dev",
        "libssl-dev",
    ]

    build_system = "cmake"
    configure = "-DCMAKE_CXX_COMPILER=g++-10"

    apt_run_dependencies = [
        "zlib1g",
        pybuild.find_non_dev_version("libssl-dev"),
    ]
