# -*- python -*-

import pybuild


class ValgrindBuilder(pybuild.ProgramBuilder):
    name = "valgrind"

    source_repository = "https://sourceware.org/git/valgrind.git"
    git_tag_regex = r"^(svn/)?VALGRIND_(?P<major>\d+)_(?P<minor>\d+)_(?P<patch>\d+)$"

    apt_build_dependencies = [
        # Standard
        "make",
        "g++",
        "pkg-config",
        "git",
        "autoconf",
    ]

    build_system = "autoconf"

    apt_run_dependencies = []
