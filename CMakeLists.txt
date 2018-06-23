CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(stm32-mpu ASM C CXX)

SET(TARGET ${PROJECT_NAME})

SET(TARGET_ELF ${TARGET}.elf)
SET(TARGET_BIN ${TARGET}.bin)
SET(TARGET_HEX ${TARGET}.hex)

# disable cmake compiler checks
SET(CMAKE_C_COMPILER_WORKS 1)

SET(CMAKE_SYSTEM_PROCESSOR arm)
SET(CMAKE_CROSSCOMPILING 1)

# do not use -rdynamic flag
SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
SET(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

###############################################################################
# collect sources
FILE(GLOB_RECURSE ASM_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/**.s)
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
        ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-fixture/source
)


###############################################################################
SET(PREFIX arm-none-eabi-)

SET(CMAKE_ASM_COMPILER ${PREFIX}gcc)
SET(CMAKE_C_COMPILER ${PREFIX}gcc)
SET(CMAKE_CXX_COMPILER ${PREFIX}g++)
SET(OBJCOPY_COMMAND ${PREFIX}objcopy)
SET(SIZE_COMMAND ${PREFIX}size)


SET(CPU "-mcpu=cortex-m3")
SET(MCU "${CPU} -mthumb ${FPU} ${FLOAT-ABI}")
SET(AS_DEFS "")
SET(C_DEFS "-DUSE_HAL_DRIVER -DSTM32F103xB")
SET(CPP_DEFS "-DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER -DUSE_HAL_DRIVER -DSTM32F103xB")
SET(AS_INCLUDES "")

SET(CMAKE_ASM_FLAGS " -x assembler-with-cpp ${MCU} ${AS_DEFS} ${AS_INCLUDES} ${OPT} -Wall -fdata-sections -ffunction-sections")
SET(CMAKE_C_FLAGS "-g -gdwarf-2 ${MCU} ${C_DEFS} ${C_INCLUDES} ${OPT} -Wall -fdata-sections -ffunction-sections")
SET(CMAKE_CXX_FLAGS "-g -gdwarf-2 -std=gnu++14 -mthumb ${CPU} ${CPP_DEFS} ${C_INCLUDES} ${OPT} -fstack-usage -fno-threadsafe-statics   -Wall -ffunction-sections -O0")

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -MMD -MP")

SET(LDSCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/cubemx-generated/STM32F103C8Tx_FLASH.ld)

SET(CMAKE_EXE_LINKER_FLAGS "${MCU} -specs=nano.specs -T${LDSCRIPT} ${LIBDIR} ${LIBS} -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.map,--cref -Wl,--gc-sections")

ADD_EXECUTABLE(${TARGET_ELF} ${C_SOURCES_SRC} ${C_SOURCES_DRV} ${CPP_SOURCES_SRC} ${ASM_SOURCES})
TARGET_LINK_LIBRARIES(${TARGET_ELF} nosys c m)

###############################################################################
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

ADD_CUSTOM_TARGET(
    FLASH
  COMMAND
    st-flash write ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_BIN} 0x8000000
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
    ${TARGET_BIN}
)

