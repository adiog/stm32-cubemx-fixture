This repository contains the initial project setup for STM32F103CB.

# Preconditions:
- there is a CubeMX generated *BASIC* code for *makefile* located in cubemx-generated.
- the script cubemx_fixture.sh is run once afterwards.
- the stlink toolkit is installed (see submodule in tools/stlink).
- the project will be build with cmake.
- the project will be flashed with stlink and st-flash command.
- the remote debugger can be used with st-util.

# Enable Remote Debug on CLion (sample configuration):
Edit configuration -> Add New Configuration -> GDB Remote Debug:
- GDB: arm-none-eabi-gdb
- target-remote: localhost:4242
- Symbol file: cmake-build-debug/stm32-cubemx-fixture.elf
- (recommended) add stutil_singleton_debug.sh as an external tool before Debug configuration
