#!/bin/bash

timetrap out $2
task "$1" stop
timetrap display
