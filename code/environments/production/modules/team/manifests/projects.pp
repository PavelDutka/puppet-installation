class team::projects {
  # Copy blender_for_projects
  file { 'C:/Users/Public/Desktop/blender_for_projects':
    ensure             => directory,
    source             => 'puppet:///modules/setup_blender/blender_for_projects',
    recurse            => true,
    force              => true,
    sourceselect       => all,
    source_permissions => ignore,
    replace            => true,
  }

  # Copy blender_for_products
  file { 'C:/Users/Public/Desktop/blender_for_products':
    ensure             => directory,
    source             => 'puppet:///modules/setup_blender/blender_for_products',
    recurse            => true,
    force              => true,
    sourceselect       => all,
    source_permissions => ignore,
    replace            => true,
  }

  # Ensure PowerShell script exists on the node
  file { 'C:/setup_scripts/CreateShortcuts.ps1':
    ensure  => 'file',
    source  => 'puppet:///modules/team/CreateShortcuts.ps1',
    mode    => '0755',
  }

  # Run PowerShell script to create shortcuts on Desktop
  exec { 'create_shortcuts_on_desktop':
    command  => 'powershell.exe -ExecutionPolicy Bypass -File C:/setup_scripts/CreateShortcuts.ps1',
    provider => powershell,
    unless   => 'Test-Path "C:/Users/Public/Desktop/blender_for_products.lnk" -and Test-Path "C:/Users/Public/Desktop/blender_for_projects.lnk"',
  }

  # Ensure the PinShortcuts.ps1 script exists on the node
  file { 'C:/setup_scripts/PinShortcuts.ps1':
    ensure  => 'file',
    source  => 'puppet:///modules/team/PinShortcuts.ps1',
    mode    => '0755',
  }

  # Run PowerShell script to pin shortcuts to taskbar
  exec { 'pin_shortcuts_to_taskbar':
    command => 'powershell.exe -ExecutionPolicy Bypass -File C:/setup_scripts/PinShortcuts.ps1',
    provider => powershell,
    onlyif   => 'Test-Path "C:/Users/Public/Desktop/blender_for_products.lnk" -and Test-Path "C:/Users/Public/Desktop/blender_for_projects.lnk"',
  }
}
