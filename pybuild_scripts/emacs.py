# -*- python -*-

import pybuild


class EmacsBuilder(pybuild.ProgramBuilder):
    name = "emacs"

    source_repository = "git://git.sv.gnu.org/emacs.git"
    git_tag_regex = r"^emacs-(?P<version>\d+\.\d+)$"

    apt_build_dependencies = [
        # Standard
        "make",
        "g++",
        "pkg-config",
        "git",
        "autoconf",
        # Emacs specific
        "gnutls-dev",
        "libx11-dev",
        "libxaw7-dev",
        "libjpeg-dev",
        "libpng-dev",
        "libtiff-dev",
        "libncurses-dev",
        "libgif-dev",
        "texinfo",
    ]

    build_system = "autoconf"
    configure = "--with-x-toolkit=lucid"

    apt_run_dependencies = [
        "libgnutls30",
        "libx11-6",
        "libxaw7",
        "libjpeg8",
        "libxml2",
        "libpng16-16",
        "libgif7",
        "libtiff5",
        "libtiffxx5",
        "libtinfo6",
        "libncurses6",
    ]
