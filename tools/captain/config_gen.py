# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "click",
#     "psutil",
# ]
# ///
import argparse
from pathlib import Path
from typing import Dict, List
import psutil

import click

# Map of target names to their associated fuzzing programs
PROGRAMS: Dict[str, List[str]] = {
    "libpng": ["libpng_read_fuzzer"],
    "libsndfile": ["sndfile_fuzzer"],
    "libtiff": ["tiff_read_rgba_fuzzer", "tiffcp"],
    "libxml2": ["libxml2_xml_read_memory_fuzzer", "xmllint"],
    "lua": ["lua"],
    "openssl": ["asn1", "asn1parse", "bignum", "server", "client", "x509"],
    "php": ["json", "exif", "unserialize", "parser"],
    "poppler": ["pdf_fuzzer", "pdfimages", "pdftoppm"],
    "sqlite3": ["sqlite3_fuzz"],
    "demo": ["demo"],
}

# Map of patch prefixes to target names
PATCH_TO_TARGET = {
    "PNG": "libpng",
    "SND": "libsndfile",
    "TIF": "libtiff",
    "XML": "libxml2",
    "LUA": "lua",
    "SSL": "openssl",
    "PHP": "php",
    "PDF": "poppler",
    "SQL": "sqlite3",
    "DEM": "demo",
}


def get_target_from_patch(patch_name: str) -> str:
    prefix = patch_name[:3]
    if prefix not in PATCH_TO_TARGET:
        raise ValueError(f"Invalid patch name: {patch_name}")
    return PATCH_TO_TARGET[prefix]


def generate_captain_config(args: argparse.Namespace) -> None:
    # Get the number of physical cores
    physical_cores = psutil.cpu_count(logical=False)
    workers = (physical_cores // args.repeat) * args.repeat
    workers = max(workers, args.repeat)
    # Generate base config
    config = [
        f"WORKDIR={args.workdir}",
        f"REPEAT={args.repeat}",
        f"WORKERS={workers}",
        f"WORKER_POOL={' '.join(str(x) for x in range(1, physical_cores + 1))}",
        f"TIMEOUT={args.timeout}",
        f"POLL={args.poll}",
        f"FUZZERS=({' '.join(args.fuzzers)})",
    ]

    if args.early_exit:
        config.append("EARLY_EXIT=1")

    # Get unique targets from patches
    targets = {get_target_from_patch(patch) for patch in args.patches}

    cnt = 0
    # Generate fuzzer-specific configs
    for fuzzer in args.fuzzers:
        # Add targets for this fuzzer
        config.append(f"{fuzzer}_TARGETS=({' '.join(targets)})")

        # Add patches for each target
        for target in targets:
            # Get patches that apply to this target
            target_patches = [
                p for p in args.patches if get_target_from_patch(p) == target
            ]
            config.append(f"{fuzzer}_{target}_PATCHES=({' '.join(target_patches)})")

            # Add programs for this target
            target_programs = PROGRAMS[target]
            config.append(f"{fuzzer}_{target}_PROGRAMS=({' '.join(target_programs)})")

            cnt += len(target_patches) * len(target_programs) * args.repeat

    print(f"Total cores needed: {cnt}.")

    Path("captainrc").write_text("\n".join(config) + "\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--fuzzers", type=str, required=True, nargs="+")
    parser.add_argument("-p", "--patches", type=str, required=True, nargs="+")
    parser.add_argument("-w", "--workdir", type=str, default="workdir")
    parser.add_argument("--repeat", type=int, default=10)
    parser.add_argument("--timeout", type=str, default="24h")
    parser.add_argument("--poll", type=int, default=1)
    parser.add_argument("--early-exit", type=bool, default=False)
    args = parser.parse_args()

    generate_captain_config(args)
