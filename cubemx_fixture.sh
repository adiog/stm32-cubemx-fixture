#!/bin/bash
# Copyright 2018 Aleksander Gajewski <adiog@brainfuck.pl>
#   created:  Sat 23 Jun 2018 06:22:14 PM CEST
#   modified: Sat 23 Jun 2018 06:28:20 PM CEST

# BASH CLEANUP {{{
# PRIVATE:
BASH_TMPDIR=/dev/shm/
BASH_MKTEMP="mktemp --tmpdir=$BASH_TMPDIR"
BASH_CLEANUP_FILE=`$BASH_MKTEMP`
trap BASH_CLEANUP EXIT

function BASH_CLEANUP() {
  tac $BASH_CLEANUP_FILE | bash
  rm $BASH_CLEANUP_FILE
}

# PUBLIC:
function FINALLY() {
  echo "$*" >> $BASH_CLEANUP_FILE
}

function MKTEMP() {
  BASH_TMP=`$BASH_MKTEMP`
  FINALLY "rm $BASH_TMP"
  echo $BASH_TMP
}

function MKTEMP_DIR() {
  BASH_TMP=`$BASH_MKTEMP -d`
  FINALLY "rm -fr $BASH_TMP"
  echo $BASH_TMP
}
# }}}


CUBEMX_GENERATED_MAIN_C=cubemx-generated/Src/main.c
CUBEMX_GENERATED_LD_SCRIPT=`find cubemx-generated/ -name "*_FLASH.ld"`

CUBEMX_FIXTURE=cubemx-fixture
CUBEMX_FIXTURE_SRC=${CUBEMX_FIXTURE}/Src
CUBEMX_FIXTURE_INC=${CUBEMX_FIXTURE}/Inc

mkdir -p ${CUBEMX_FIXTURE_SRC}
mkdir -p ${CUBEMX_FIXTURE_INC}

CUBEMX_FIXTURE_MAIN_C=${CUBEMX_FIXTURE_SRC}/cubemx_fixture_main.c
CUBEMX_FIXTURE_MAIN_H=${CUBEMX_FIXTURE_INC}/cubemx_fixture_main.h

mv ${CUBEMX_GENERATED_MAIN_C} ${CUBEMX_FIXTURE_MAIN_C}

sed -e "s#int main(void)#int cubemx_fixture_main(void)#g" -i ${CUBEMX_FIXTURE_MAIN_C}
sed -e "s#.*/\* USER CODE END WHILE \*/.*#&\rreturn;#g" -i ${CUBEMX_FIXTURE_MAIN_C}

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
CUBEMX_FIXTURE_LD_SCRIPT=cubemx-fixture/${CUBEMX_FIXTURE_LD_SCRIPT}
CUBEMX_FIXTURE_WITH_SEMIHOST_LD_SCRIPT=cubemx-fixture/${CUBEMX_FIXTURE_LD_SCRIPT/.ld/.SEMIHOST.ld}
cp ${CUBEMX_GENERATED_LD_SCRIPT} ${CUBEMX_FIXTURE_LD_SCRIPT}
cp ${CUBEMX_GENERATED_LD_SCRIPT} ${CUBEMX_FIXTURE_WITH_SEMIHOST_LD_SCRIPT}

(
echo "GROUP ("
echo "   libnosys.a"
echo ")"
) >> ${CUBEMX_FIXTURE_LD_SCRIPT}

