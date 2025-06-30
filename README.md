# MicroPython

This repository provides [MicroPython](https://micropython.org/) builds for BeagleBoard.org boards.

## Setup

If this is your first time using zephyr, [Install Zephyr SDK](https://docs.zephyrproject.org/latest/develop/getting_started/index.html#install-the-zephyr-sdk) before following the steps below.

1. Create a workspace folder:

```shell
mkdir micropython-workspace
cd micropython-workspace
```

2. Setup virtualenv

```shell
python -m venv .venv
source .venv/bin/activate
pip install west cc1352-flasher
```

3. Setup Zephyr app:

```shell
west init -m https://github.com/beagleboard/micropython-builder.git --mf upstream_boards/west.yml .
west update
```

4. Install python deps

```shell
west packages pip --install
```

## Build

```shell
west build -p -b ${BOARD} modules/lib/micropython/ports/zephyr -d build
```

## Flash

```shell
west flash
```

## Helpful Links

- [MicroPython](https://micropython.org/)
