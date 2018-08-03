#!/bin/bash

# echo "Installing the package..."
# npm install
# echo "Done."

echo "Running webpack..."
npm run build
echo "Done."

echo "Copying the bundle to the Luna Studio plugin"
cp -r dist ../../dist/user-config/atom/packages/luna-studio/node_modules/node_editor_basegl
echo "Done."

echo "Copying the styles to Atom"
cp dist/style/* ../atom/styles/gen
echo "Done."
