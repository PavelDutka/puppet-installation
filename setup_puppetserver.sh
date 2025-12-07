#!/bin/bash

# Install Puppet
dnf -y install https://yum.puppet.com/puppet-release-el-9.noarch.rpm
dnf -y install puppetserver
systemctl enable --now puppetserver

# Open Puppet port in firewall
firewall-cmd --permanent --add-port=8140/tcp
firewall-cmd --reload

# Write puppet.conf
cat > /etc/puppetlabs/puppet/puppet.conf <<EOF
[main]
environment = production
certname = serverus
server = serverus

[master]
reports = store
pluginsync = true
EOF

# Install required Puppet modules
puppet module install puppetlabs-registry
puppet module install puppetlabs-powershell
puppet module install puppetlabs-chocolatey
puppet module install rfbennett-windows_shortcuts
puppet module install puppetlabs-scheduled_task
puppet module install rfbennett-file_lnk

# Restart Puppetserver to apply configuration
systemctl restart puppetserver

# You need to run "exec bash" to use puppet commands
# Copy code manually from git to /etc/puppetlabs/code/