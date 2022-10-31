# -*- python -*-

import pybuild


class SolveSpaceBuilder(pybuild.ProgramBuilder):
    name = "solvespace"

    source_repository = "https://github.com/solvespace/solvespace.git"
    git_tag_regex = r"^v(?P<version>\d+\.\d+)$"

    apt_build_dependencies = [
        # Standard
        "git",
        "cmake",
        "make",
        "ninja-build",
        "g++",
        # Library specific
        "zlib1g-dev",
        "libpng-dev",
        "libcairo2-dev",
        "libfreetype6-dev",
        "libjson-c-dev",
        "libfontconfig1-dev",
        "libgtkmm-3.0-dev",
        "libpangomm-1.4-dev",
        "libgl-dev",
        "libglu-dev",
        "libspnav-dev",
    ]

    build_system = "cmake"
    configure = ""

    apt_run_dependencies = [
        "zlib1g",
        "libpng16-16",
        "libcairo2",
        "libfreetype6",
        "libjson-c5",
        "libfontconfig1",
        "libgtkmm-3.0-1v5",
        "libpangomm-1.4-1v5",
        "libgl1",
        "libglu1-mesa",
        "libspnav0",
    ]
