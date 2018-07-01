This repository contains the initial project setup for STM32F103CB.
![stm32f103-pinout-diagram](https://github.com/adiog/stm32-cubemx-fixture/raw/master/docs/stm32f103-pinout-diagram.gif "STM32F103 Pinout Diagram")

# Goals:
- work with CLion to edit, flash and debug the code.
- besides generated code use modern C++ out of the box.

# Preconditions:
- there is a CubeMX generated *BASIC* code for *makefile* located in cubemx-generated.
- the script cubemx_fixture.sh is run once afterwards.
- the stlink toolkit is installed (see submodule in tools/stlink).
- the arm compiler toolchain is installed (for debian: apt install gcc-arm-none-eabi gdb-arm-none-eabi).
- the project will be build with cmake.
- the project will be flashed with stlink and st-flash command.
- the remote debugger can be used with st-util.
- screen is installed (for debian: apt install screen).

# Enable Remote Debug on CLion (sample configuration):
Edit configuration -> Add New Configuration -> GDB Remote Debug:
- GDB: arm-none-eabi-gdb
- target-remote: localhost:4242
- Symbol file: cmake-build-debug/stm32-cubemx-fixture.elf
- Before run: Run Another Configuration "RESTART_DEBUG_SERVER"

# Enable Remote Debug on CLion (with Semihosting):
Edit configuration -> Add New Configuration -> GDB Remote Debug:
- GDB: tools/arm-none-eabi-gdb-semihost
- target-remote: localhost:4242
- Symbol file: cmake-build-debug/stm32-cubemx-fixture-semihost.elf
- Before run: Run Another Configuration "RESTART_DEBUG_SEMIHOST_SERVER"
- Run in side terminal: tools/follow_semihosting_stdout --follow
![clion-semihost-config](https://github.com/adiog/stm32-cubemx-fixture/raw/master/docs/clion-semihost-config.png "CLion Semihosting configuration")

# Gentle reminder:
- ensure that none elf file is specified in CLion configuration executable (keep "Not Selected").


