#!/bin/bash

# Create dist directory if it doesn't exist
mkdir -p dist

# Compile Elm to JavaScript
elm make src/Main.elm --output=dist/main.js

# Copy HTML template to dist
cp index.html dist/index.html

echo "Build completed successfully!"
echo "Open dist/index.html in your browser to play the game."