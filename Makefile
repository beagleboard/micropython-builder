PB2_TARGET = pocketbeagle_2-am6254-a53

ZEPHYR_REV ?= main
MICROPYTHON_REV ?= master

define WEST_YML
manifest:
  self:
    west-commands: scripts/west-commands.yml

  remotes:
    - name: zephyrproject-rtos
      url-base: https://github.com/zephyrproject-rtos
    - name: micropython
      url-base: https://github.com/micropython

  projects:
    - name: zephyr
      remote: zephyrproject-rtos
      revision: ${ZEPHYR_REV}
      import:
        name-allowlist:
          - hal_ti
          - cmsis_6

    - name: micropython
      remote: micropython
      revision: ${MICROPYTHON_REV}
      path: modules/lib/micropython
      submodules: true
endef

app/west.yml:
	$(info Creating west.yml)
	$(shell mkdir -p $(@D))
	$(file > $@,$(WEST_YML))

%/zephyr/zephyr.bin:
	$(info "Building MicroPython")
	west build -b $$(echo $* | sed 's/-/\//g') -d $* modules/lib/micropython/ports/zephyr

dist/%.bin: %/zephyr/zephyr.bin
	$(info "Copying to dist")
	mkdir -p dist
	cp $*/zephyr/zephyr.bin dist/$*.bin

dist/%.bin.xz: dist/%.bin
	$(info "Compressing MicroPython")
	xz -z dist/$*.bin

${PB2_TARGET}.img:
	$(info "Downloading PocketBeagle 2 Zephyr image")
	wget https://github.com/beagleboard/bb-zephyr-images/releases/download/continuous-release/pocketbeagle_2_zephyr.img.xz -O ${PB2_TARGET}.img.xz
	xz -d ${PB2_TARGET}.img.xz

dist/${PB2_TARGET}.img.xz: ${PB2_TARGET}/zephyr/zephyr.bin ${PB2_TARGET}.img
	$(info "Building PocketBeagle 2 A53 MicroPython")
	mcopy -i ${PB2_TARGET}.img ${PB2_TARGET}/zephyr/zephyr.bin ::
	xz -z ${PB2_TARGET}.img
	mv ${PB2_TARGET}.img.xz dist/${PB2_TARGET}.img.xz
