#!/bin/bash

# Define the Puppet module paths
MODULES_DIR="/etc/puppetlabs/code/environments/production/modules"

# Create necessary directories for the team and hardware modules
mkdir -p "$MODULES_DIR/team/manifests"
mkdir -p "$MODULES_DIR/hardware/manifests"
mkdir -p "$MODULES_DIR/role/manifests"

# Create the team manifests
cat <<EOL > "$MODULES_DIR/team/manifests/marketing.pp"
class team::marketing {
  file { 'C:/Users/Public/Desktop/marketing_team.txt':
    ensure  => 'file',
    content => "Welcome to the Marketing team!",
  }
}
EOL

cat <<EOL > "$MODULES_DIR/team/manifests/product.pp"
class team::product {
  file { 'C:/Users/Public/Desktop/product_team.txt':
    ensure  => 'file',
    content => "Welcome to the Products team!",
  }
}
EOL

cat <<EOL > "$MODULES_DIR/team/manifests/projects.pp"
class team::projects {
  file { 'C:/Users/Public/Desktop/projects_team.txt':
    ensure  => 'file',
    content => "Welcome to the Projects team!",
  }
}
EOL

cat <<EOL > "$MODULES_DIR/team/manifests/code.pp"
class team::code {
  file { 'C:/Users/Public/Desktop/code_team.txt':
    ensure  => 'file',
    content => "Welcome to the Code team!",
  }
}
EOL

# Create the hardware manifests
cat <<EOL > "$MODULES_DIR/hardware/manifests/igpu.pp"
class hardware::igpu {
  file { 'C:/Users/Public/Desktop/igpu_info.txt':
    ensure  => 'file',
    content => "This machine has an integrated GPU.",
  }
}
EOL

cat <<EOL > "$MODULES_DIR/hardware/manifests/gpu.pp"
class hardware::gpu {
  file { 'C:/Users/Public/Desktop/gpu_info.txt':
    ensure  => 'file',
    content => "This machine has a dedicated GPU.",
  }
}
EOL

# Create the role manifests
cat <<EOL > "$MODULES_DIR/role/manifests/marketing_igpu.pp"
class role::marketing_igpu {
  include team::marketing
  include hardware::igpu
}
EOL

cat <<EOL > "$MODULES_DIR/role/manifests/projects_gpu.pp"
class role::projects_gpu {
  include team::projects
  include hardware::gpu
}
EOL

# Create the setup_environment manifest
cat <<EOL > "/etc/puppetlabs/code/environments/production/manifests/setup_environment.pp"
class setup_environment {
  
  exec { 'Set-ExecutionPolicy':
    command => 'powershell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force"',
    onlyif  => 'powershell.exe -Command "(Get-ExecutionPolicy -Scope Process) -ne \'Bypass\'"',
  }

  exec { 'Install-Boxstarter':
    command => 'powershell.exe -Command "(Invoke-WebRequest -useb https://boxstarter.org/bootstrapper.ps1) | Invoke-Expression; get-boxstarter -Force"',
    require => Exec['Set-ExecutionPolicy'],
    unless  => 'powershell.exe -Command "Get-Command -Name boxstarter -ErrorAction SilentlyContinue"',
  }

  exec { 'Enable-UAC':
    command => 'powershell.exe -Command "Enable-UAC"',
  }

  exec { 'Enable-MicrosoftUpdate':
    command => 'powershell.exe -Command "Enable-MicrosoftUpdate"',
  }

  exec { 'Install-WindowsUpdate':
    command => 'powershell.exe -Command "Install-WindowsUpdate -AcceptEula"',
    require => [Exec['Enable-UAC'], Exec['Enable-MicrosoftUpdate']],
  }

  registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock':
    values => {
      'AllowDevelopmentWithoutDevLicense' => { value => 1, type => 'dword' },
    },
    ensure => present,
  }

  registry_key { 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem':
    values => {
      'LongPathsEnabled' => { value => 1, type => 'dword' },
    },
    ensure => present,
  }

  exec { 'Set-WindowsExplorerOptions':
    command => 'powershell.exe -Command "Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar"',
  }

  exec { 'Disable-GameBarTips':
    command => 'powershell.exe -Command "Disable-GameBarTips"',
  }

  exec { 'Confirm-ChocolateyPrompts':
    command => 'powershell.exe -Command "choco feature enable -n allowGlobalConfirmation"',
  }

  $packages = [
    'python3 --version=3.11.6',
    'google-drive-file-stream',
    'git',
    'llvm',
    'golang',
    'pngquant',
    'visualstudio2022community',
    'visualstudio2022-workload-nativedesktop',
    'visualstudio2022-workload-nativegame',
    'netfx-4.6.1-devpack',
    'graphviz',
  ]

  $packages.each |$pkg| {
    exec { "Upgrade-${pkg}":
      command => "choco upgrade ${pkg}",
      require => Exec['Confirm-ChocolateyPrompts'],
    }
  }

  $pip_packages = [
    'wheel',
    'mypy',
    'debugpy',
    'mkdocs',
    'mkdocs-excluder-plugin',
    'mkdocs-macros-plugin',
    'mkdocs-material',
    'mkdocs-material-extensions',
    'mkdocs-mermaid2-plugin',
    'mkdocs-monorepo-plugin',
    'mkdocs-video',
    'cx-Freeze',
  ]

  $pip_packages.each |$pip_pkg| {
    exec { "Upgrade-pip-${pip_pkg}":
      command => "powershell.exe -Command 'pip3 install --upgrade ${pip_pkg}'",
    }
  }

  exec { 'Install-bazelisk':
    command => 'powershell.exe -Command "go install github.com/bazelbuild/bazelisk@latest"',
  }

  exec { 'Create-Bazel-Hardlink':
    command => 'powershell.exe -Command "New-Item -ItemType HardLink -Path $HOME/go/bin/bazel.exe -Target $HOME/go/bin/bazelisk.exe"',
    onlyif => 'powershell.exe -Command "Test-Path $HOME/go/bin/bazel.exe"',
  }

  file { "${HOME}/.bazelrc":
    ensure  => present,
    content => "# short output base on Windows to avoid running into path length limits\nstartup --output_base=C:/bz\nbuild --disk_cache=C:/bz_cache\nbuild --repository_cache=C:/bz_cache/bazel_repository_cache\n",
  }

  file { "${HOME}/.bashrc":
    ensure  => present,
    content => "# no duplicates\nHISTCONTROL=ignoredups:erasedups\nHISTSIZE=100000\nHISTFILESIZE=100000\nshopt -s histappend\nPROMPT_COMMAND='history -a'\n",
  }

}

node default {
  include setup_environment
}
EOL

echo "Puppet manifests created successfully."
