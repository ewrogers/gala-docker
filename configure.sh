#!/bin/bash

read -p "Enter your Gala email: " email
read -s -p "Enter your Gala password (will be hidden): " password

echo "GALA_EMAL=${email}" >.env
echo "GALA_PASSWORD=${password}" >>.env
echo "NODE_SPECIFIER=1" >> .env

echo ""
echo "Configuration file generated successfully!"

