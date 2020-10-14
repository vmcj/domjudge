#!/bin/bash

make configure
./configure --with-baseurl='http://localhost/domjudge/'
make install-docs
make clean

cd doc/manual/
make version.py
./gen_conf_ref.py
sphinx-build -b html . build

gitlab/setupcss.sh
vnu-runtime-image/bin/vnu --css /domjudge/doc/manual/build/html/_static/*.css

