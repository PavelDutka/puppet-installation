# Include setup_blender for every node
include setup_blender
include setup_environment

node /^marketing-/ { 
  include role::marketing_igpu
}

node /^projects-desktop/ {
  include role::projects_gpu
}

node /^code-/ {
  include role::code
}

node /^products-/ {
  include role::marketing_igpu
}

node default {
  # Get the node name
  $node_name = $facts['fqdn']

  # Check if the node name matches a valid convention (otherwise, write to the Public Desktop)
  if !($node_name =~ /^marketing-/ or $node_name =~ /^projects-/ or $node_name =~ /^code-/) {
    # Path to the Public Desktop (accessible to all users)
    $desktop_path = 'C:/Users/Public/Desktop'

    # Ensure the Public Desktop directory exists
    file { $desktop_path:
      ensure => directory,
    }

    # Write the warning file to the Public Desktop
    file { 'bad_naming_convention.txt':
      path    => "${desktop_path}/bad_naming_convention.txt",
      content => "Warning: Node '${node_name}' has an incorrect naming convention.\n",
      ensure  => 'file',
    }
  }
}
