#!/bin/bash

set -euo pipefail

GIT_REPO=git://git.sv.gnu.org/emacs.git

TARBALL_LOCATION=http://ftpmirror.gnu.org/emacs

DEPENDENCIES=(
    # General build utilities
    make g++ pkg-config

    # Checked in ./configure
    gnutls-dev libx11-dev libxaw7-dev libjpeg-dev
    libpng-dev libtiff-dev libncurses-dev libgif-dev
)

FROM_GIT_DEPENDENCIES=(
    git autoconf
)

FROM_TARBALL_DEPENDENCIES=(
    wget
)

function show_short_usage() {
        cat <<EOF
Usage: emacs.sh
        [-v|--version EMACS_VERSION]
        [--use-git-repo] [--use-release-tarball]
        [--build-dir BUILD_DIR]
        [-j|--jobs NUM_JOBS]
        [--install-dir INSTALL_DIR]
        [--install] [--no-install]
        [--sudo-install] [--no-sudo-install]
        [--clean] [--no-clean]
        [-h|--help]
EOF
}

function show_usage() {
    show_short_usage
    cat <<EOF

-v, --version

        The version of emacs to be built.  If "latest", then the
        latest full release will be used.

--use-git-repo, --use-release-tarball

        From where to download the source code for emacs.  Default is
        --use-git-repo.

--build-dir BUILD_DIR

        The directory in which to download and build emacs.  Defaults
        to a temporary directory made with mktemp.  Using a temporary
        directory is incompatible with --no-clean.

-j NUM_JOBS, --jobs NUM_JOBS

        The number of jobs to run the compilation process with.
        Defaults to 4.

--install-dir INSTALL_DIR

        The install location for emacs.  The final executable will be
        installed to INSTALL_DIR/bin/emacs.  Defaults to /usr/local.

--install, --no-install

        Whether to call "make install" after compilation.  Defaults to
        --install.

--sudo-install, --no-sudo-install

        Whether to use "sudo" when calling "make install".  Defaults
        to --sudo-install if sudo is necessary to write to write to
        INSTALL_DIR, and --no-sudo-install otherwise.

--clean, --no-clean

        Whether to remove the build directory after compilation.
        Defaults to --clean if --install, or to --no-clean if
        --no-install.

-h, --help

        Display this help message.

EOF

}

#################################################
###          Start of argument parsing        ###
#################################################

trap "show_short_usage >&2" ERR
args=$(getopt \
           --name emacs.sh \
           --options "hv:j:" \
           --longoptions "version:,jobs:" \
           --longoptions "build-dir:,install-dir:" \
           --longoptions "install,no-install" \
           --longoptions "sudo-install,no-sudo-install" \
           --longoptions "clean,no-clean" \
           --longoptions "help" \
           --unquoted \
           -- "$@")
trap - ERR
set -- $args

VERSION=latest
BUILD_DIR=
INSTALL_DIR=/usr/local
INSTALL=true
SUDO_INSTALL=
CLEAN=
NUM_JOBS=4
DOWNLOAD_FROM=git

while (( $# )); do
    case "$1" in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;

        --use-git-repo)
            DOWNLOAD_FROM=git
            shift
            ;;

        --use-release-tarball)
            DOWNLOAD_FROM=release_tarball
            shift
            ;;

        --build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;

        -j|--jobs)
            NUM_JOBS="$2"
            shift 2
            ;;

        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;

        --install)
            INSTALL=true
            shift
            ;;

        --no-install)
            INSTALL=false
            shift
            ;;

        --clean)
            CLEAN=true
            shift
            ;;

        --no-clean)
            CLEAN=false
            shift
            ;;

        --sudo-install)
            SUDO_INSTALL=true
            shift
            ;;

        --no-sudo-install)
            SUDO_INSTALL=false
            shift
            ;;

        -h|--help)
            show_usage
            exit 0
            ;;

        --)
            shift
            break
            ;;

        -*|--*)
            echo "Error: Unknown flag: $1"
            show_short_usage >&2
            exit 1
            ;;

        *)
            echo "Internal Error: getopt should output -- before positional" >&2
            exit 2
            ;;
    esac
done

if (( $# )); then
    echo "Unexpected positional argument: $1" >&2
    show_short_usage >&2
    exit 1
fi

# Make full list of dependencies
if [[ "${DOWNLOAD_FROM}" == git ]]; then
    DEPENDENCIES+=( "${FROM_GIT_DEPENDENCIES[@]}" )
elif [[ "${DOWNLOAD_FROM}" == release_tarball ]]; then
    DEPENDENCIES+=( "${FROM_TARBALL_DEPENDENCIES[@]}" )
else
    echo "Unknown source location: ${DOWNLOAD_FROM}" >&2
    show_short_usage >&2
    exit 1
fi

# Default: Clean up the build directory after installation.
if [[ -z "${CLEAN}" ]]; then
    CLEAN="${INSTALL}"
fi

# Default: Use sudo if needed to write to the install directory,
# otherwise don't.
if [[ -z "${SUDO_INSTALL}" ]]; then
    WALK_DIR="${INSTALL_DIR}"
    while true; do
        if [[ "${WALK_DIR}" == / ]]; then
            SUDO_INSTALL=true
            break
        elif [[ -d "${WALK_DIR}" ]]; then
            if [[ -w "${WALK_DIR}" ]]; then
                SUDO_INSTALL=false
            else
                SUDO_INSTALL=true
            fi
            break
        fi
        WALK_DIR="$(dirname "${WALK_DIR}")"
    done
fi

# Default: Make a temporary build directory
if [[ -z "${BUILD_DIR}" ]]; then
    if "${CLEAN}"; then
        BUILD_DIR=$(mktemp --tmpdir --directory build-emacs.XXXXXXXX)
    else
        echo "Cannot use temporary build directory with --no-clean" >&2
        show_short_usage >&2
        exit 1
    fi
fi

# In case the build directory doesn't exist yet.
mkdir -p "${BUILD_DIR}"

# Clean-up of the build directory if requested
if "${CLEAN}"; then
    trap "rm -rf ${BUILD_DIR}" EXIT
fi

# Check latest version of emacs.
if [[ "${VERSION}" == latest ]]; then
    VERSION=$(git ls-remote --tags --refs --sort="v:refname" "${GIT_REPO}" | \
                  cut -f2 | \
                  sed 's_refs/tags/emacs-__' | \
                  grep -E '^[0-9]+.[0-9]+$' | \
                  tail -n1)
fi

GIT_TAG=emacs-$VERSION

#################################################
###          End of argument parsing          ###
#################################################

# Download dependencies if needed
if apt-get install --dry-run "${DEPENDENCIES[@]}" 2> /dev/null | grep Inst; then
    sudo apt install "${DEPENDENCIES[@]}"
fi

# Download emacs source code
cd "${BUILD_DIR}"

if [[ "${DOWNLOAD_FROM}" == git ]]; then
    if [[ -d emacs ]]; then
        # Repo already cloned, switch to the requested tag.
        cd emacs
        git fetch --tags --depth=1 origin $GIT_TAG
        git checkout $GIT_TAG
    else
        # Clone repository
        git clone --depth=1 --branch $GIT_TAG $GIT_REPO
        cd emacs
    fi
    ./autogen.sh

elif [[ "${DOWNLOAD_FROM}" == release_tarbal ]]; then
    # Download a tarball release
    if [[ ! -d $GIT_TAG ]]; then
        wget http://ftpmirror.gnu.org/emacs/$GIT_TAG.tar.gz
        tar -xzf $GIT_TAG.tar.gz
    fi
    cd $GIT_TAG
fi

# Compile emacs.
#
# - Use the lucid toolkit due to avoid bug with emacs in daemon mode
#   using GTK toolkit.  https://unix.stackexchange.com/a/56945/68824
#
# - Use --without-makeinfo to avoid needing the large texinfo package
#   to build local documentation.
./configure --prefix "${INSTALL_DIR}" --with-x-toolkit=lucid --without-makeinfo
make --jobs=$NUM_JOBS

# Install, if requested
if "${INSTALL}"; then
    if "${SUDO_INSTALL}"; then
        sudo make install
    else
        make install
    fi
fi
