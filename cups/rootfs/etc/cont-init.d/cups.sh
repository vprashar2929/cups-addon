#!/usr/bin/with-contenv bash

# Create CUPS data directories for persistence
mkdir -p /data/cups/cache
mkdir -p /data/cups/logs
mkdir -p /data/cups/state
mkdir -p /data/cups/config
mkdir -p /data/cups/config/ppd
mkdir -p /data/cups/config/ssl

# Set proper permissions
chown -R root:lp /data/cups
chmod -R 775 /data/cups

# Create CUPS configuration directory if it doesn't exist
mkdir -p /etc/cups

# Basic CUPS configuration without admin authentication
cat > /data/cups/config/cupsd.conf << EOL
# Listen on all interfaces (IPv4 and IPv6)
Port 631

# Accept requests with any hostname/IP
ServerAlias *

# Enable web interface
WebInterface Yes

# Default settings
DefaultAuthType None
Browsing On
BrowseLocalProtocols dnssd
JobSheets none,none
PreserveJobHistory No

# Allow access from anywhere
<Location />
  Order allow,deny
  Allow all
</Location>

<Location /admin>
  Order allow,deny
  Allow all
</Location>

<Location /admin/conf>
  Order allow,deny
  Allow all
</Location>

<Location /admin/log>
  Order allow,deny
  Allow all
</Location>

<Policy default>
  <Limit All>
    Order deny,allow
  </Limit>
</Policy>
EOL

# Create a symlink from the default config location to our persistent location
ln -sf /data/cups/config/cupsd.conf /etc/cups/cupsd.conf
ln -sf /data/cups/config/printers.conf /etc/cups/printers.conf
ln -sf /data/cups/config/ppd /etc/cups/ppd
ln -sf /data/cups/config/ssl /etc/cups/ssl

# Start CUPS service
/usr/sbin/cupsd -f