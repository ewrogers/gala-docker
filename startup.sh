#!/bin/bash

echo "Starting Gala node ${NODE_SPECIFIER}... (email=${GALA_EMAIL})"
exec gala-headless-node email=$GALA_EMAIL password=$GALA_PASSWORD specifier=$NODE_SPECIFIER
