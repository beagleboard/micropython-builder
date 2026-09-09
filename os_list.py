#!/bin/python3

from pathlib import Path
import hashlib
import datetime
import subprocess
import argparse
import json

DIST = Path("dist/")
FILE_MAP = {
    "beagleconnect_freedom.bin.xz": "beagleconnect-freedom",
    "pocketbeagle_2-am6254-a53.bin.xz": "pocketbeagle2-am62",
}

DISCRIPTION = "MicroPython is a lean and efficient implementation of the Python 3 programming language, specifically designed to run on microcontrollers and other embedded systems"
ICON = "https://media.githubusercontent.com/media/beagleboard/bb-imager-rs/refs/heads/main/assets/os/micropython.webp"


def get_file_sha256(file_path: Path) -> str:
    # Open the file in binary read mode ('rb')
    with open(file_path, "rb") as f:
        # Generate the file digest using SHA-256
        digest = hashlib.file_digest(f, "sha256")
    return digest.hexdigest()


def get_xz_extract_size(file_path: Path) -> int:
    out = subprocess.run(
        ["xz", "--robot", "--list", file_path],
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    return int(out.splitlines()[-1].split("\t")[4])


def os_image(
    devices: [str],
    image_download_size: int,
    image_download_sha256: str,
    url: str,
    release_date: str,
    extract_size: int,
):
    return {
        "name": "MicroPython",
        "description": DISCRIPTION,
        "icon": ICON,
        "url": url,
        "image_download_size": image_download_size,
        "image_download_sha256": image_download_sha256,
        "extract_size": extract_size,
        "release_date": release_date,
        "devices": devices,
    }


if __name__ == "__main__":
    assert DIST.is_dir()

    parser = argparse.ArgumentParser()
    parser.add_argument("tag", help="Release tag for constructing urls", type=str)
    args = parser.parse_args()

    release_date = datetime.datetime.now().strftime("%Y-%m-%d")
    base_url = f"https://github.com/beagleboard/micropython-builder/releases/download/{args.tag}"

    items = filter(lambda x: x.name in FILE_MAP, DIST.iterdir())
    data = list(
        map(
            lambda item: os_image(
                [FILE_MAP[item.name]],
                item.stat().st_size,
                get_file_sha256(item),
                f"{base_url}/{item.name}",
                release_date,
                get_xz_extract_size(item),
            ),
            items,
        )
    )

    with open(f"{DIST}/os_list.json", "w") as fp:
        json.dump({"imager": {}, "os_list": data}, fp)
