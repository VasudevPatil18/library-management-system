#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web
flutter config --enable-web
flutter pub get

# Build
flutter build web --release
