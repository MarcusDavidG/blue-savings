#!/bin/bash
# Build Docker image
echo "Building Docker image..."
docker build -t bluesavings-frontend:latest .
echo "Build complete!"
