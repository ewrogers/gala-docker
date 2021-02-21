#!/bin/bash

echo "Starting Gala node..."
exec gala-headless-node email=$GALA_EMAIL password=$GALA_PASSWORD specifier=$NODE_SPECIFIER
