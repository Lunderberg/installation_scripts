# -*- python -*-

import pybuild


class CMakeBuilder(pybuild.ProgramBuilder):
    name = "cmake"

    source_repository = "https://github.com/Kitware/CMake"
    git_tag_regex = r"^v(?P<version>\d+\.\d+\.\d+)$"

    apt_build_dependencies = [
        # Standard
        "git",
        "make",
        "g++",
        # Library specific
        "libssl-dev",
        # "zlib1g-dev",
        # "libpng-dev",
        # "libcairo2-dev",
        # "libfreetype6-dev",
        # "libjson-c-dev",
        # "libfontconfig1-dev",
        # "libgtkmm-3.0-dev",
        # "libpangomm-1.4-dev",
        # "libgl-dev",
        # "libglu-dev",
        # "libspnav-dev",
    ]

    build_system = "makefile"

    @property
    def configure(self):
        return [
            "./bootstrap",
            f"--prefix={self.install_directory}",
            "--parallel=$(nproc)",
            "--",
            "-DCMAKE_BUILD_TYPE:STRING=Release",
        ]

    apt_run_dependencies = [
        # "zlib1g",
        # "libpng16-16",
        # "libcairo2",
        # "libfreetype6",
        # "libjson-c5",
        # "libfontconfig1",
        # "libgtkmm-3.0-1v5",
        # "libpangomm-1.4-1v5",
        # "libgl1",
        # "libglu1-mesa",
        # "libspnav0",
    ]
