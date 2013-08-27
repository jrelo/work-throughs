all: build bin bin/hello bin/template bin/upcase bin/hexdump

build:
	mkdir build

bin:
	mkdir bin

ASM := nasm -f elf -g -F stabs
LD := ld

build/hello.o: src/hello.asm
	$(ASM) -o $@ $<

bin/hello: build/hello.o
	$(LD) -o $@ $<

build/template.o: src/template.asm
	$(ASM) -o $@ $<

bin/template: build/template.o
	$(LD) -o $@ $<

build/upcase.o: src/upcase.asm
	$(ASM) -o $@ $<

bin/upcase: build/upcase.o
	$(LD) -o $@ $<

build/hexdump.o: src/hexdump.asm
	$(ASM) -o $@ $<

bin/hexdump: build/hexdump.o
	$(LD) -o $@ $<
debug:
	make bin/template && gdb -x .gdbinit bin/template

clean:
	rm -rf build bin
