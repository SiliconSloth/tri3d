# tri3d

This is an attempt to make an open-source hardware-accelerated 3D graphics pipeline for N64 homebrew games, for use in conjunction with libdragon.

Most of the pipeline is currently on the CPU, with the RDP being used to draw triangles.  I am currently in the process of moving the pipeline to the RSP to boost performance.

## Compilation

tri3d can be built using the [libdragon](https://github.com/DragonMinded/libdragon) toolchain by running `make`.  The [armips](https://github.com/Kingcom/armips) assembler is used to assemble the microcode and must be available on the system path.

## Acknowledgements

The file `lib/N64_RDP.asm` was generated from the file `n64-rdp.arch` included in [bass](https://github.com/ARM9/bass).

The other two files in the `lib` directory were generated from the files in the `LIB` directory of PeterLemon's [N64 assembly demos](https://github.com/PeterLemon/N64).

The profiling code in `profile.c` and `profile.h` was provided by [rasky](https://github.com/rasky).