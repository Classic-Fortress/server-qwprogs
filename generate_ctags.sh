#!/usr/bin/env bash

rm *tags
fteqcc64 -ftags ./ssqc/progs.src
fteqcc64 -ftags ./csqc/csprogs.src
fteqcc64 -ftags ./menu/menu.src
cat *.tags|LC_COLLATE=C sort>tags
rm *.tags
