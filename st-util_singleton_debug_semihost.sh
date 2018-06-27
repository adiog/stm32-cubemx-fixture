#!/bin/bash

pidof st-util && killall st-util
screen -d -m -S st-util-semihost bash -c st-util --semihosting &
