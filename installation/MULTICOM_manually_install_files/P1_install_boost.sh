#!/bin/bash -e

echo " Start compile boost (will take ~20 min)
"

cd /home/casp14/MULTICOM_db_tools//tools

cd boost_1_55_0

./bootstrap.sh  --prefix=/home/casp14/MULTICOM_db_tools//tools/boost_1_55_0

./b2

./b2 install

