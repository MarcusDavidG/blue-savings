#!/bin/bash
# Fix linting issues
echo "Fixing linting issues..."
npm run lint -- --fix
npm run format
echo "Linting fixed!"
