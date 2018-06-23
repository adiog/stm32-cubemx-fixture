#!/bin/bash

pidof st-util && killall st-util
st-util &
