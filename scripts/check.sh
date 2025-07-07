#!/bin/bash

set -e

echo "🔍 Running elm format..."
elm-format src/ --validate

echo "🔍 Running elm make..."
elm make src/Main.elm --optimize --output=dist/main.js

echo "🔍 Running elm test..."
elm-test

echo "✅ All checks passed!"