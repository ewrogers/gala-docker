#!/usr/bin/env bash
set -e

CONFIG_JSON=$(cat "$GALA_CONFIG_FILE")

# Generate a unique machine ID for this container
if [[ ! -f /etc/machine-id ]]; then
  echo "Generating unique machine ID..."
  rm -f /etc/machine-id /var/lib/dbus/machine-id
  dbus-uuidgen --ensure=/etc/machine-id
  dbus-uuidgen --ensure
fi

# Update email address
if [[ -n $GALA_EMAIL ]]; then
  CONFIG_JSON=$(echo "$CONFIG_JSON" | jq \
    --arg email "$GALA_EMAIL" \
    '.email |= $email')

  echo "$CONFIG_JSON" > "$GALA_CONFIG_FILE"
fi

# Update password
if [[ -n $GALA_PASSWORD ]]; then
  CONFIG_JSON=$(echo "$CONFIG_JSON" | jq \
    --arg password "$GALA_PASSWORD" \
    '.password |= $password')

  echo "$CONFIG_JSON" > "$GALA_CONFIG_FILE"
fi

# Run the gala node daemon
exec gala-node daemon
