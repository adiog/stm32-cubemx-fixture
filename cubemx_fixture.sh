#!/bin/bash

CUBEMX_GENERATED_MAIN_C=cubemx-generated/Src/main.c
CUBEMX_GENERATED_MSP_C=cubemx-generated/Src/stm32f1xx_hal_msp.c
CUBEMX_GENERATED_LD_SCRIPT=`find cubemx-generated/ -name "*_FLASH.ld"`

CUBEMX_FIXTURE=cubemx-fixture
CUBEMX_FIXTURE_SRC=${CUBEMX_FIXTURE}/Src
CUBEMX_FIXTURE_INC=${CUBEMX_FIXTURE}/Inc

mkdir -p ${CUBEMX_FIXTURE_SRC}
mkdir -p ${CUBEMX_FIXTURE_INC}

CUBEMX_FIXTURE_MAIN_C=${CUBEMX_FIXTURE_SRC}/cubemx_fixture_main.c
CUBEMX_FIXTURE_MAIN_H=${CUBEMX_FIXTURE_INC}/cubemx_fixture_main.h

test -e ${CUBEMX_GENERATED_MAIN_C} \
  && mv ${CUBEMX_GENERATED_MAIN_C} ${CUBEMX_FIXTURE_MAIN_C} \
  && sed -e "s#int main(void)#int cubemx_fixture_main(void)#g" -i ${CUBEMX_FIXTURE_MAIN_C} \
  && sed -e "s#.*/\* USER CODE END WHILE \*/.*#&\rreturn;#g" -i ${CUBEMX_FIXTURE_MAIN_C}

CUBEMX_FIXTURE_MSP_C=${CUBEMX_FIXTURE_SRC}/stm32f1xx_hal_msp.c

test -e ${CUBEMX_GENERATED_MSP_C} \
    && mv ${CUBEMX_GENERATED_MSP_C} ${CUBEMX_FIXTURE_MSP_C} \
    && sed -e "s#  __HAL_AFIO_REMAP_SWJ_DISABLE();#// &#" -i ${CUBEMX_FIXTURE_MSP_C}

(
echo '#pragma once'
echo '#ifdef __cplusplus'
echo 'extern "C" {'
echo '#endif'
echo 'int cubemx_fixture_main(void);'
echo '#ifdef __cplusplus'
echo '}'
echo '#endif'
) > ${CUBEMX_FIXTURE_MAIN_H}

find cubemx-generated -name Examples -exec rm -fr {} \;
find cubemx-generated -name Templates -exec rm -fr {} \;
find cubemx-generated -name "*_template.c" -exec rm -fr {} \;

CUBEMX_FIXTURE_LD_SCRIPT_BASENAME=$(basename ${CUBEMX_GENERATED_LD_SCRIPT})
CUBEMX_FIXTURE_LD_SCRIPT=cubemx-fixture/${CUBEMX_FIXTURE_LD_SCRIPT_BASENAME}
CUBEMX_FIXTURE_WITH_SEMIHOST_LD_SCRIPT=cubemx-fixture/${CUBEMX_FIXTURE_LD_SCRIPT_BASENAME/.ld/.SEMIHOST.ld}
cp ${CUBEMX_GENERATED_LD_SCRIPT} ${CUBEMX_FIXTURE_LD_SCRIPT}
cp ${CUBEMX_GENERATED_LD_SCRIPT} ${CUBEMX_FIXTURE_WITH_SEMIHOST_LD_SCRIPT}

(
echo "GROUP ("
echo "   libnosys.a"
echo ")"
) >> ${CUBEMX_FIXTURE_LD_SCRIPT}

