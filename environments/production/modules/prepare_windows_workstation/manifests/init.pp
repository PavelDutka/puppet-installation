class prepare_windows_workstation {

include chocolatey

# Ensure Boxstarter is installed
package { 'boxstarter':
  ensure => latest,
  provider => 'chocolatey',
}

# Enable UAC (User Account Control)
exec { 'enable_uac':
  command => 'powershell.exe -Command "Enable-UAC"',
  unless=> 'powershell.exe -Command "(Get-ItemProperty -Path \'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\' -Name EnableLUA).EnableLUA" | Select-String -Pattern "1"',
  provider => 'powershell',
}

# Ensure Developer Mode is enabled
registry_key { 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock':
  ensure => present,
}

# Set the Developer Mode registry value
registry_value { 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowDevelopmentWithoutDevLicense':
  ensure => present,
  type => 'string',
  data => '1',
}

# Enable Long Paths support
registry_key { 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem':
  ensure => present,
}

registry_value { 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled':
  ensure => present,
  type => 'dword',
  data => 1,
}

# Show hidden files folders, don't show protected, show extensions everywhere
exec { 'enable_windows_explorer_options':
  command => 'powershell.exe -Command "Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar"',
  unless=> 'powershell.exe -Command "Get-ItemProperty -Path \'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\' | Select-Object -ExpandProperty Hidden"',
  provider => 'powershell',
}

# Don't show game screencasting tips when running 3D accelerated apps
exec { 'disable_game_bar_tips':
  command => 'Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowTips" -Value 0',
  unless=> 'Test-Path "HKCU:\Software\Microsoft\GameBar\ShowTips" -and (Get-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowTips").ShowTips -eq 0',
  provider => 'powershell',
}

# packages to install
$choco_packages = [
  'google-drive-file-stream',
  'git',
  'llvm',
  'golang',
  'pngquant',
  'visualstudio2022community',
  'netfx-4.6.1-devpack',
  'graphviz',
  'vscode',
  'discord',
  'nodejs',
  'slack',
  'ffmpeg',
]

package { $choco_packages:
  ensure   => installed,
  provider => 'chocolatey',
}

package { 'googlechrome':
  ensure          => installed,
  provider        => 'chocolatey',
  install_options => ['--ignore-checksums'],
}

package { 'python':
  ensure   => '3.11.9',
  provider => 'chocolatey',
  install_options => ['--force'],
}

# Install Visual Studio 2022 workloads (require VS Community)
package { 'visualstudio2022-workload-nativedesktop':
  ensure   => installed,
  provider => 'chocolatey',
  require  => Package['visualstudio2022community'],
}

package { 'visualstudio2022-workload-nativegame':
  ensure   => installed,
  provider => 'chocolatey',
  require  => Package['visualstudio2022community'],
}

  package { ['wheel', 'mypy', 'debugpy']:
    ensure   => present,
    provider => 'pip',
    require  => Package['python'],
  }

  package { ['mkdocs', 'mkdocs-excluder-plugin', 'mkdocs-material']:
    ensure   => present,
    provider => 'pip',
    require  => Package['python'],
  }

  package { 'cx-Freeze':
    ensure   => present,
    provider => 'pip',
    require  => Package['python'],
  }

# add cze and eng keyboard layout
exec { 'set_keyboard_layouts':
  command => 'powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "Set-WinUserLanguageList -LanguageList en-US, cs-CZ -Force"',
  unless=> 'powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "$layouts = (Get-WinUserLanguageList).LanguageTag; ($layouts -contains \'en-US\') -and ($layouts -contains \'cs-CZ\')"',
  provider=> 'powershell',
}

}
