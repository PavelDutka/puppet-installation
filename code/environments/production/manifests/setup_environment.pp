class setup_environment {

  # Ensure PowerShell execution policy is set to Bypass
  exec { 'Set-ExecutionPolicy':
    command => 'powershell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force"',
    onlyif  => 'powershell.exe -Command "(Get-ExecutionPolicy -Scope Process) -ne \'Bypass\'"',
  }

  # Check if the script is running as Administrator
  exec { 'Check-Administrator':
    command => 'powershell.exe -Command "[System.Windows.Forms.Messagebox]::Show(\'Not running as administrator!\')"',
    onlyif  => 'powershell.exe -Command "[Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)" -eq $false"',
  }

  # Download and install Boxstarter
  exec { 'Install-Boxstarter':
    command => 'powershell.exe -Command "(Invoke-WebRequest -useb https://boxstarter.org/bootstrapper.ps1) | Invoke-Expression; get-boxstarter -Force"',
    require => Exec['Set-ExecutionPolicy'],
    unless  => 'powershell.exe -Command "Get-Command -Name boxstarter -ErrorAction SilentlyContinue"',
  }

  # Enable UAC only if it is not already enabled
  exec { 'Enable-UAC':
    command => 'powershell.exe -Command "Enable-UAC"',
    onlyif  => 'powershell.exe -Command "Get-UACStatus -ErrorAction SilentlyContinue -eq $false"',
  }

  # Enable Microsoft Update
  exec { 'Enable-MicrosoftUpdate':
    command => 'powershell.exe -Command "Enable-MicrosoftUpdate"',
    onlyif  => 'powershell.exe -Command "Get-MicrosoftUpdateStatus -ErrorAction SilentlyContinue -eq $false"',
  }

  # Install Windows Updates if not already installed
  exec { 'Install-WindowsUpdate':
    command => 'powershell.exe -Command "Install-WindowsUpdate -AcceptEula"',
    require => [Exec['Enable-UAC'], Exec['Enable-MicrosoftUpdate']],
    unless  => 'powershell.exe -Command "Get-WindowsUpdateStatus -ErrorAction SilentlyContinue -eq $true"',
  }

  # Turn on Developer Mode
  registry_key { 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock':
    values => {
      'AllowDevelopmentWithoutDevLicense' => { value => 1, type => 'dword' },
    },
    ensure => present,
  }

  # Enable Long Paths
  registry_key { 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem':
    values => {
      'LongPathsEnabled' => { value => 1, type => 'dword' },
    },
    ensure => present,
  }

  # Show hidden files, don't show protected files, show extensions everywhere
  exec { 'Set-WindowsExplorerOptions':
    command => 'powershell.exe -Command "Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar"',
    onlyif => 'powershell.exe -Command "Get-WindowsExplorerOptions -ShowHiddenFiles -ErrorAction SilentlyContinue -ne $true"',
  }

  # Disable Game Bar Tips
  exec { 'Disable-GameBarTips':
    command => 'powershell.exe -Command "Disable-GameBarTips"',
    onlyif  => 'powershell.exe -Command "Get-GameBarTipsStatus -ErrorAction SilentlyContinue -eq $true"',
  }

  # Chocolatey configuration to allow global confirmation
  exec { 'Confirm-ChocolateyPrompts':
    command => 'powershell.exe -Command "choco feature enable -n allowGlobalConfirmation"',
    onlyif  => 'powershell.exe -Command "choco feature list --local-only | Select-String -Pattern "allowGlobalConfirmation: true" -ErrorAction SilentlyContinue"',
  }

  # Upgrade various packages via Chocolatey
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

  # Iterate over each package and upgrade
  $packages.each |$pkg| {
    exec { "Upgrade-${pkg}":
      command => "powershell.exe -Command \"choco upgrade ${pkg}\"",
      require => Exec['Confirm-ChocolateyPrompts'],
      onlyif => "powershell.exe -Command \"choco list --local-only | Select-String -Pattern '${pkg}'\"",
    }
  }

  # Install Python packages using pip
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

  # Iterate over each pip package and upgrade
  $pip_packages.each |$pip_pkg| {
    exec { "Upgrade-pip-${pip_pkg}":
      command => "powershell.exe -Command 'pip3 install --upgrade ${pip_pkg}'",
      onlyif => "powershell.exe -Command \"pip3 show ${pip_pkg} -ErrorAction SilentlyContinue\"",
    }
  }

  # Install Bazelisk
  exec { 'Install-bazelisk':
    command => 'powershell.exe -Command "go install github.com/bazelbuild/bazelisk@latest"',
    onlyif => 'powershell.exe -Command "Get-Command bazelisk -ErrorAction SilentlyContinue"',
  }

  # Create Bazel hardlink
  exec { 'Create-Bazel-Hardlink':
    command => 'powershell.exe -Command "New-Item -ItemType HardLink -Path ${env['HOME']}/go/bin/bazel.exe -Target ${env['HOME']}/go/bin/bazelisk.exe"',
    onlyif => 'powershell.exe -Command "Test-Path ${env['HOME']}/go/bin/bazel.exe"',
  }

  # Create .bazelrc file if it doesn't exist
  file { "${env['HOME']}/.bazelrc":
    ensure  => present,
    content => "# short output base on Windows to avoid running into path length limits\nstartup --output_base=C:/bz\nbuild --disk_cache=C:/bz_cache\nbuild --repository_cache=C:/bz_cache/bazel_repository_cache\n",
  }

  # Set up .bashrc settings
  file { "${env['HOME']}/.bashrc":
    ensure  => present,
    content => "# no duplicates\nHISTCONTROL=ignoredups:erasedups\nHISTSIZE=100000\nHISTFILESIZE=100000\nshopt -s histappend\nPROMPT_COMMAND='history -a'\n",
  }

}
