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
