class setup_blender {

  # Define source directories on the Puppet server
  $source_blender_products = '/etc/puppetlabs/code/environments/production/modules/setup_blender/files/blender_for_products/'
  $source_blender_projects = '/etc/puppetlabs/code/environments/production/modules/setup_blender/files/blender_for_projects/'

  # Define target directories on the node
  $target_blender_products = 'C:/blender_for_products'
  $target_blender_projects = 'C:/blender_for_projects'

  # Create target directories
  file { $target_blender_products:
    ensure => directory,
  }

  file { $target_blender_projects:
    ensure => directory,
  }

  # Copy files from source to target directories
  file { "${target_blender_products}/":
    ensure  => directory,
    source  => $source_blender_products,
    recurse => true,
  }

  file { "${target_blender_projects}/":
    ensure  => directory,
    source  => $source_blender_projects,
    recurse => true,
  }

  # Pin the executables to the taskbar
  exec { 'pin_blender_for_products':
    command => "powershell -command \"New-Item -ItemType HardLink -Path 'C:/blender_for_products/blender_for_products.exe.lnk' -Target 'C:/blender_for_products/blender_for_products.exe'\"",
    path    => 'C:/Windows/System32',
    onlyif  => "Test-Path 'C:/blender_for_products/blender_for_products.exe'",
    require => File["${target_blender_products}/"],
  }

  exec { 'pin_blender_for_projects':
    command => "powershell -command \"New-Item -ItemType HardLink -Path 'C:/blender_for_projects/blender_for_projects.exe.lnk' -Target 'C:/blender_for_projects/blender_for_projects.exe'\"",
    path    => 'C:/Windows/System32',
    onlyif  => "Test-Path 'C:/blender_for_projects/blender_for_projects.exe'",
    require => File["${target_blender_projects}/"],
  }

}

