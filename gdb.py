#!/usr/bin/env python3

import argparse
import contextlib
import io
import pathlib
import urllib.request
import urllib.parse
import re
import subprocess
import sys
import tarfile
import tempfile

from multiprocessing import cpu_count


def parse_version(version_str):
    return tuple(int(x) for x in version_str.split("."))


def extract_version(filename):
    res = re.match("^gdb-(?P<version_str>\d+(\.\d+)*)\..*$", filename)
    if res:
        return parse_version(res.group("version_str"))
    else:
        return None


def get_release_links():
    source_url = "https://ftp.gnu.org/gnu/gdb/"
    res = urllib.request.urlopen(source_url)
    content = res.read().decode("utf-8")
    links = [
        match.group("link") for match in re.finditer('href="(?P<link>.*?)"', content)
    ]
    output = {}
    for link in links:
        version = extract_version(link)
        if version is not None:
            if version not in output:
                output[version] = {}

            attr = "sig" if link.endswith(".sig") else "tarball"
            value = urllib.parse.urljoin(source_url, link)
            output[version][attr] = value
    return output


def get_tarball(url, outdir):
    res = urllib.request.urlopen(url)
    with io.BytesIO(res.read()) as fileobj:
        archive = tarfile.open(fileobj=fileobj)

        top_dir_names = set(f.name.split("/")[0] for f in archive)
        assert len(top_dir_names) == 1
        top_dir_name = next(iter(top_dir_names))

        archive.extractall(outdir)
        return outdir / top_dir_name


def main(args):
    release_links = get_release_links()

    if args.version is None:
        version = max(release_links)
    else:
        version = args.version

    tarball_url = release_links[version]["tarball"]

    stack = contextlib.ExitStack()
    with stack:
        if args.work_dir is None:
            work_dir = stack.enter_context(
                tempfile.TemporaryDirectory(prefix="gdb-build-")
            )
        else:
            work_dir = args.work_dir
        work_dir = pathlib.Path(work_dir)

        src_dir = get_tarball(tarball_url, work_dir)

        subprocess.check_call(
            [
                src_dir / "configure",
                f"--prefix={args.install_dir}",
                f"--with-python={sys.executable}",
                # Use any apt-provided debug symbols and auto-load files.
                f"--with-separate-debug-dir=/usr/lib/debug",
                f"--with-auto-load-dir=/usr/share/gdb/auto-load",
            ],
            cwd=src_dir,
        )
        subprocess.check_call(["make", f"-j{args.num_threads}"], cwd=src_dir)
        subprocess.check_call(["make", "install"], cwd=src_dir)


def normalize_path(path):
    return pathlib.Path(path).expanduser().resolve()


def arg_main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pdb",
        action="store_true",
        help="Start a pdb post mortem on uncaught exception",
    )
    parser.add_argument(
        "-v", "--version", type=parse_version, help="The version of gdb to use."
    )
    parser.add_argument(
        "--work-dir",
        type=normalize_path,
        default=None,
        help="Location in which to download the source files and perform the build.  If unspecified, defaults to a temporary directory.",
    )
    parser.add_argument(
        "--install-dir",
        type=normalize_path,
        required=True,
        help="Install location of the gdb executable.",
    )
    parser.add_argument(
        "-j",
        "--jobs",
        dest="num_threads",
        type=int,
        default=max(1, int(0.75 * cpu_count())),
    )

    args = parser.parse_args()

    try:
        main(args)
    except Exception:
        if args.pdb:
            import pdb, traceback

            traceback.print_exc()
            pdb.post_mortem()
        raise


if __name__ == "__main__":
    arg_main()
