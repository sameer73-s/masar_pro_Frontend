#!/bin/bash
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$PWD/flutter/bin"
flutter doctor
flutter build web --release
