#!/bin/bash

# Create necessary directories
mkdir -p /etc/puppetlabs/code/environments/production/modules/team/manifests \
         /etc/puppetlabs/code/environments/production/modules/hardware/manifests \
         /etc/puppetlabs/code/environments/production/modules/role/manifests

# Create team manifests
cat > /etc/puppetlabs/code/environments/production/modules/team/manifests/marketing.pp <<EOF
class team::marketing {
  file { "C:/Users/Public/Desktop/marketing_team.txt":
    ensure  => "file",
    content => "Welcome to the Marketing team!",
  }
}
EOF

cat > /etc/puppetlabs/code/environments/production/modules/team/manifests/product.pp <<EOF
class team::product {
  file { "C:/Users/Public/Desktop/product_team.txt":
    ensure  => "file",
    content => "Welcome to the Products team!",
  }
}
EOF

cat > /etc/puppetlabs/code/environments/production/modules/team/manifests/projects.pp <<EOF
class team::projects {
  file { "C:/Users/Public/Desktop/projects_team.txt":
    ensure  => "file",
    content => "Welcome to the Projects team!",
  }
}
EOF

cat > /etc/puppetlabs/code/environments/production/modules/team/manifests/code.pp <<EOF
class team::code {
  file { "C:/Users/Public/Desktop/code_team.txt":
    ensure  => "file",
    content => "Welcome to the Code team!",
  }
}
EOF

# Create hardware manifests
cat > /etc/puppetlabs/code/environments/production/modules/hardware/manifests/igpu.pp <<EOF
class hardware::igpu {
  file { "C:/Users/Public/Desktop/igpu_info.txt":
    ensure  => "file",
    content => "This machine has an integrated GPU.",
  }
}
EOF

cat > /etc/puppetlabs/code/environments/production/modules/hardware/manifests/gpu.pp <<EOF
class hardware::gpu {
  file { "C:/Users/Public/Desktop/gpu_info.txt":
    ensure  => "file",
    content => "This machine has a dedicated GPU.",
  }
}
EOF

# Create role manifests
cat > /etc/puppetlabs/code/environments/production/modules/role/manifests/marketing_igpu.pp <<EOF
class role::marketing_igpu {
  include team::marketing
  include hardware::igpu
}
EOF

cat > /etc/puppetlabs/code/environments/production/modules/role/manifests/projects_gpu.pp <<EOF
class role::projects_gpu {
  include team::projects
  include hardware::gpu
}
EOF

# Append node definitions to site.pp
cat >> /etc/puppetlabs/code/environments/production/manifests/site.pp <<EOF
node /^marketing-/ {
  include role::marketing_igpu
}
node /^projects-desktop/ {
  include role::projects_gpu
}
EOF

echo "Puppet manifests created successfully!"
