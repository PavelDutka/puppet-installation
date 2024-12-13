class setup_environment {

  # Ensure PowerShell execution policy is set to Bypass
  exec { 'Set-ExecutionPolicy':
    command => 'powershell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force"',
    onlyif  => 'powershell.exe -Command "(Get-ExecutionPolicy -Scope Process) -ne \'Bypass\'"',
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

  # Enable Developer Mode only if it is not already enabled
  registry_key { 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock':
    values => {
      'AllowDevelopmentWithoutDevLicense' => { value => 1, type => 'dword' },
    },
    ensure => present,
  }

  # Enable Long Paths only if not already enabled
  registry_key { 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem':
    values => {
      'LongPathsEnabled' => { value => 1, type => 'dword' },
    },
    ensure => present,
  }

  # Show hidden files and folders only if the setting is not already applied
  exec { 'Set-WindowsExplorerOptions':
    command => 'powershell.exe -Command "Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar"',
    onlyif => 'powershell.exe -Command "Get-WindowsExplorerOptions -ShowHiddenFiles -ErrorAction SilentlyContinue -ne $true"',
  }

  # Disable Game Bar Tips only if it's enabled
  exec { 'Disable-GameBarTips':
    command => 'powershell.exe -Command "Disable-GameBarTips"',
    onlyif => 'powershell.exe -Command "Get-GameBarTipsStatus -ErrorAction SilentlyContinue -eq $true"',
  }

  # Chocolatey Configuration
  exec { 'Confirm-ChocolateyPrompts':
    command => 'powershell.exe -Command "choco feature enable -n allowGlobalConfirmation"',
    onlyif => 'powershell.exe -Command "choco feature list --local-only | Select-String -Pattern "allowGlobalConfirmation: true" -ErrorAction SilentlyContinue"',
  }

  # Package list
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

  # Upgrade each package in the list
  $packages.each |$pkg| {
    exec { "Upgrade-${pkg}":
      command => "choco upgrade ${pkg}",
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

  # Upgrade each pip package
  $pip_packages.each |$pip_pkg| {
    exec { "Upgrade-pip-${pip_pkg}":
      command => "powershell.exe -Command 'pip3 install --upgrade ${pip_pkg}'",
      onlyif => "powershell.exe -Command \"pip3 show ${pip_pkg} -ErrorAction SilentlyContinue\"",
    }
  }

  # Configure Bazel settings
  exec { 'Install-bazelisk':
    command => 'powershell.exe -Command "go install github.com/bazelbuild/bazelisk@latest"',
    onlyif => 'powershell.exe -Command "Get-Command bazelisk -ErrorAction SilentlyContinue"',
  }

  exec { 'Create-Bazel-Hardlink':
    command => 'powershell.exe -Command "New-Item -ItemType HardLink -Path $env:HOME/go/bin/bazel.exe -Target $env:HOME/go/bin/bazelisk.exe"',
    onlyif => 'powershell.exe -Command "Test-Path $env:HOME/go/bin/bazel.exe"',
  }

  # Create .bazelrc if it doesn't exist
  file { "${env['HOME']}/.bazelrc":
    ensure  => present,
    content => "# short output base on Windows to avoid running into path length limits\nstartup --output_base=C:/bz\nbuild --disk_cache=C:/bz_cache\nbuild --repository_cache=C:/bz_cache/bazel_repository_cache\n",
  }

  # Create .bashrc settings if it doesn't exist
  file { "${env['HOME']}/.bashrc":
    ensure  => present,
    content => "# no duplicates\nHISTCONTROL=ignoredups:erasedups\nHISTSIZE=100000\nHISTFILESIZE=100000\nshopt -s histappend\nPROMPT_COMMAND='history -a'\n",
  }
 
  # First, ensure English language pack is installed
  exec { 'install-language-pack':
    provider => powershell,
    command  => '
      # Install English language pack
      $ProgressPreference = "SilentlyContinue"
      Install-Language en-US -CopyToSettings
    ',
    unless   => 'Get-InstalledLanguage en-US',
    logoutput => true,
  }

  # Set display language and other settings
  exec { 'set-display-language':
    provider => powershell,
    command  => '
      # Set display language to English
      Set-WinUILanguageOverride -Language en-US
      
      # Set display language for welcome screen and new users
      Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"
      
      # Set display language for system accounts
      $MUISettings = "HKLM:\SOFTWARE\Policies\Microsoft\MUI\Settings"
      New-Item -Path $MUISettings -Force
      Set-ItemProperty -Path $MUISettings -Name "PreferredUILanguages" -Value "en-US" -Type MultiString
      
      # Set user locale settings
      Set-WinUILanguageOverride -Language en-US
      Set-WinSystemLocale en-US
      Set-Culture en-US
      Set-WinHomeLocation -GeoId 244
      
      # Force Windows to use English display language
      $UserLanguageList = New-WinUserLanguageList -Language "en-US"
      $UserLanguageList[0].Handwriting = 1
      Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
    ',
    logoutput => true,
    require   => Exec['install-language-pack'],
  }

  # Create a startup task to ensure settings persist
  exec { 'create-display-language-task':
    provider => powershell,
    command  => '
      $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command Set-WinUILanguageOverride -Language en-US"
      $Trigger = New-ScheduledTaskTrigger -AtStartup
      $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
      Register-ScheduledTask -TaskName "SetWindowsDisplayLanguage" -Action $Action -Trigger $Trigger -Principal $Principal -Force
    ',
    unless   => 'Get-ScheduledTask -TaskName "SetWindowsDisplayLanguage" -ErrorAction SilentlyContinue',
    require  => Exec['set-display-language'],
  }

  notify { 'display_language_notice':
    message => 'Display language settings have been updated. Please restart the computer for all changes to take effect.',
    require => [Exec['set-display-language'], Exec['create-display-language-task']],
  }

 
    #create host user
   user { 'host':
   ensure => present,
   password => 'guest',
   groups => 'Administrators'
  }

}
