#!/bin/bash

# Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Shared library
pushd dart_services
./tool/travis.sh
popd

# Dart only compiler (with legacy flutter_web)
pushd dart_compiler
./tool/travis.sh
popd
