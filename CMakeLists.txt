CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(stm32-cubemx-fixture ASM C CXX)

SET(TARGET ${PROJECT_NAME})

SET(TARGET_ELF ${TARGET}.elf)
SET(TARGET_BIN ${TARGET}.bin)
SET(TARGET_HEX ${TARGET}.hex)

SET(TARGET_SEMIHOST_ELF ${TARGET}-semihost.elf)
SET(TARGET_SEMIHOST_BIN ${TARGET}-semihost.bin)
SET(TARGET_SEMIHOST_HEX ${TARGET}-semihost.hex)

SET(CMAKE_SYSTEM_PROCESSOR arm)
SET(CMAKE_CROSSCOMPILING 1)

# disable cmake compiler checks
SET(CMAKE_C_COMPILER_WORKS 1)

# do not use -rdynamic flag
SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
SET(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

###############################################################################
# collect sources
FILE(GLOB_RECURSE ASM_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/**.s)
FILE(GLOB_RECURSE C_SOURCES_FIX ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-fixture/Src/**.c)
FILE(GLOB_RECURSE C_SOURCES_SRC ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/Src/**.c)
FILE(GLOB_RECURSE C_SOURCES_DRV ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/Drivers/STM32F1xx_HAL_Driver/Src/**.c)
FILE(GLOB_RECURSE CPP_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/source/**.cpp)

# point out headers
INCLUDE_DIRECTORIES(
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/Inc
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/Src
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/Drivers/STM32F1xx_HAL_Driver/Inc
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/Drivers/STM32F1xx_HAL_Driver/Inc/Legacy
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/Drivers/CMSIS/Device/ST/STM32F1xx/Include
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/Drivers/CMSIS/Include
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-fixture/Inc
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-fixture/source)


###############################################################################
SET(PREFIX arm-none-eabi-)

SET(CMAKE_ASM_COMPILER ${PREFIX}gcc)
SET(CMAKE_C_COMPILER ${PREFIX}gcc)
SET(CMAKE_CXX_COMPILER ${PREFIX}g++)
SET(GDB_COMMAND ${PREFIX}gdb)
SET(OBJCOPY_COMMAND ${PREFIX}objcopy)
SET(SIZE_COMMAND ${PREFIX}size)

SET(CPU "-mcpu=cortex-m3")
SET(FPU "")
SET(FLOAT-ABI "")
SET(MCU "${CPU} -mthumb ${FPU} ${FLOAT-ABI}")
SET(COMMON_DEFS "-DUSE_HAL_DRIVER -DSTM32F103xB")
SET(AS_DEFS "${COMMON_DEFS}")
SET(C_DEFS "${COMMON_DEFS}")
SET(CPP_DEFS "${COMMON_DEFS}")
SET(AS_INCLUDES "")

SET(CMAKE_ASM_FLAGS " -x assembler-with-cpp ${MCU} ${AS_DEFS} ${AS_INCLUDES} ${OPT} -Og -Wall -fdata-sections -ffunction-sections")
SET(CMAKE_C_FLAGS "${C_DEFS} -g -gdwarf-2 -Og ${MCU} ${C_INCLUDES} ${OPT} -Wall -fdata-sections -ffunction-sections")
SET(CMAKE_CXX_FLAGS "-g -gdwarf-2 -std=gnu++14 -mthumb ${CPU} ${CPP_DEFS} ${C_INCLUDES} ${OPT} -fstack-usage -fno-threadsafe-statics -Wall -ffunction-sections -O0")

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -MMD -MP")

SET(LDSCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-fixture/STM32F103C8Tx_FLASH.ld)
SET(LDSCRIPT_SEMIHOST ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-fixture/STM32F103C8Tx_FLASH.SEMIHOST.ld)

###############################################################################
# ELF
SET(CMAKE_EXE_LINKER_FLAGS_REGULAR "${MCU} -specs=nano.specs -T${LDSCRIPT} ${LIBDIR} ${LIBS} -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.map,--cref -Wl,--gc-sections")
ADD_EXECUTABLE(${TARGET_ELF}
        ${ASM_SOURCES}
        ${C_SOURCES_SRC}
        ${C_SOURCES_DRV}
        ${C_SOURCES_FIX}
        ${CPP_SOURCES})
SET_TARGET_PROPERTIES(${TARGET_ELF} PROPERTIES LINK_FLAGS "${CMAKE_EXE_LINKER_FLAGS_REGULAR}")
TARGET_LINK_LIBRARIES(${TARGET_ELF} c m nosys)

###############################################################################
# ELF (SEMIHOST)
SET(CMAKE_EXE_LINKER_FLAGS_SEMIHOST "${MCU} -specs=nano.specs -specs=rdimon.specs -T${LDSCRIPT_SEMIHOST} ${LIBDIR} ${LIBS} -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.SEMIHOST.map,--cref -Wl,--gc-sections")
ADD_EXECUTABLE(${TARGET_SEMIHOST_ELF}
        ${ASM_SOURCES}
        ${C_SOURCES_SRC}
        ${C_SOURCES_DRV}
        ${C_SOURCES_FIX}
        ${CPP_SOURCES})
TARGET_COMPILE_DEFINITIONS(${TARGET_SEMIHOST_ELF} PUBLIC "-DSEMIHOST")
SET_TARGET_PROPERTIES(${TARGET_SEMIHOST_ELF} PROPERTIES LINK_FLAGS "${CMAKE_EXE_LINKER_FLAGS_SEMIHOST}")
TARGET_LINK_LIBRARIES(${TARGET_SEMIHOST_ELF} c m rdimon gloss-linux)

###############################################################################
# BIN & HEX
SET(BUILD_HEX_COMMAND ${OBJCOPY_COMMAND} -O ihex ${TARGET_ELF} ${TARGET_HEX})
SET(BUILD_BIN_COMMAND ${OBJCOPY_COMMAND} -O binary -S ${TARGET_ELF} ${TARGET_BIN})

ADD_CUSTOM_TARGET(
    ${TARGET_BIN}
  COMMAND
    ${BUILD_BIN_COMMAND}
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    ${TARGET_ELF}
)

ADD_CUSTOM_TARGET(
    ${TARGET_HEX}
  COMMAND
    ${BUILD_HEX_COMMAND}
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    ${TARGET_ELF}
)

###############################################################################
# BIN & HEX (SEMIHOST)

SET(BUILD_HEX_SEMIHOST_COMMAND ${OBJCOPY_COMMAND} -O ihex ${TARGET_SEMIHOST_ELF} ${TARGET_SEMIHOST_HEX})
SET(BUILD_BIN_SEMIHOST_COMMAND ${OBJCOPY_COMMAND} -O binary -S ${TARGET_SEMIHOST_ELF} ${TARGET_SEMIHOST_BIN})

ADD_CUSTOM_TARGET(
    ${TARGET_SEMIHOST_BIN}
  COMMAND
    ${BUILD_BIN_SEMIHOST_COMMAND}
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    ${TARGET_SEMIHOST_ELF}
)

ADD_CUSTOM_TARGET(
    ${TARGET_SEMIHOST_HEX}
  COMMAND
    ${BUILD_HEX_SEMIHOST_COMMAND}
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    ${TARGET_SEMIHOST_ELF}
)

###############################################################################
# FLASH
ADD_CUSTOM_TARGET(
    FLASH
  COMMAND
    killall -9 st-util || true
  COMMAND
    st-flash write ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_BIN} 0x8000000
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    ${TARGET_BIN}
)

###############################################################################
# FLASH (SEMIHOST)
ADD_CUSTOM_TARGET(
    FLASH_SEMIHOST
  COMMAND
    killall -9 st-util || true
  COMMAND
    st-flash write ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_SEMIHOST_BIN} 0x8000000
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    ${TARGET_SEMIHOST_BIN}
)

###############################################################################
# DEBUG
ADD_CUSTOM_TARGET(
    RESTART_DEBUG_SERVER
  COMMAND
    killall -9 st-util || true
  COMMAND
    screen -S st-util -d -m bash -c st-util
  COMMAND
    echo ${CMAKE_CURRENT_SOURCE_DIR} > /tmp/cmake_current_source_dir
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    FLASH
)

###############################################################################
# DEBUG (SEMIHOST)

ADD_CUSTOM_TARGET(
    RESTART_DEBUG_SEMIHOST_SERVER
  COMMAND
    killall -9 st-util || true
  COMMAND
    screen -S st-util -d -m bash -c "st-util --semihosting"
  COMMAND
    ${CMAKE_CURRENT_SOURCE_DIR}/tools/follow_semihosting_stdout --stop
  COMMAND
    screen -S st-stdout -d -m bash -c "${CMAKE_CURRENT_SOURCE_DIR}/tools/follow_semihosting_stdout --start"
  COMMAND
    echo ${CMAKE_CURRENT_SOURCE_DIR} > /tmp/cmake_current_source_dir
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    FLASH_SEMIHOST
)

