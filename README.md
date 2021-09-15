# tri3d

This is an attempt to make an open-source hardware-accelerated 3D graphics pipeline for N64 homebrew games, for use in conjunction with libdragon.

Most of the pipeline is currently on the CPU, with the RDP being used to draw triangles.  I expect to eventually move much of the processing to the RSP in order to boost performance.

## Compilation

tri3d can be built using the [libdragon](https://github.com/DragonMinded/libdragon) toolchain by running `make`.  ARM9's fork of [bass](https://github.com/ARM9/bass) is used to assemble the microcode and must be available on the system path.

## Acknowledgements

The contents of the `lib` folder are copied from PeterLemon's [N64 assembly demos](https://github.com/PeterLemon/N64). `ucode.asm` is also based on code from that repository.

The profiling code in `profile.c` and `profile.h` was provided by [rasky](https://github.com/rasky).