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
provider=> powershell,
}

# Enable Microsoft Update
exec { 'enable_microsoft_update':
command => 'powershell.exe -Command "Enable-MicrosoftUpdate"',
unless=> 'powershell.exe -Command "(New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher().Search(\'IsInstalled=0\').Updates.Count -eq 0"',
provider=> powershell,
}

# Schedule Windows Updates for the next restart
exec { 'install_windows_updates':
command => 'powershell.exe -Command "Install-WindowsUpdate -AcceptEula -ScheduleReboot"',
unless=> 'powershell.exe -Command "(Get-WindowsUpdate -IsPending).Count -eq 0"',
provider=> powershell,
}

#Ensure Developer Mode is enabled
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
provider=> powershell,
}

# Don't show game screencasting tips when running 3D accelerated apps 
exec { 'disable_game_bar_tips':
command => 'Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowTips" -Value 0',
provider=> powershell,
unless=> 'Test-Path "HKCU:\Software\Microsoft\GameBar\ShowTips" -and (Get-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowTips").ShowTips -eq 0',
}


#choco install software

package { 'google-drive-file-stream':
ensure => 'latest',
provider => 'chocolatey',
}

package { 'git':
ensure => 'latest',
provider => 'chocolatey',
}

package { 'llvm':
ensure => 'latest',
provider => 'chocolatey',
}

package { 'golang':
ensure => 'latest',
provider => 'chocolatey',
}

package { 'pngquant':
ensure => 'latest',
provider => 'chocolatey',
}

# Install GitHub Desktop using Chocolatey
package { 'github-desktop':
ensure => installed,
provider => 'chocolatey',
}

# Install Visual Studio 2022 Community Edition
package { 'visualstudio2022community':
ensure => installed,
provider => 'chocolatey',
}

# Install Visual Studio 2022 Native Desktop Workload
package { 'visualstudio2022-workload-nativedesktop':
ensure => installed,
provider => 'chocolatey',
require=> Package['visualstudio2022community'],
}

# Install Visual Studio 2022 Native Game Workload
package { 'visualstudio2022-workload-nativegame':
ensure => installed,
provider => 'chocolatey',
require=> Package['visualstudio2022community'],
}


package { 'netfx-4.6.1-devpack':
ensure => installed,
provider => 'chocolatey',
}

package { 'graphviz':
ensure => installed,
provider => 'chocolatey',
}

# Ensure Python is installed
package { 'python3':
ensure=> installed,
provider => 'chocolatey',
}

# Ensure pip is in the PATH and installed
exec { 'install_pip':
command => '"C:\\Python311\\python.exe" -m ensurepip --upgrade',
unless=> '"C:\\Python311\\python.exe" -m pip --version',
require => Package['python3'],
}

# Upgrade wheel, mypy, debugpy
exec { 'upgrade_wheel_mypy_debugpy':
command => '"C:\\Python311\\Scripts\\pip.exe" install --upgrade wheel mypy debugpy',
unless=> '"C:\\Python311\\Scripts\\pip.exe" show wheel mypy debugpy',
require => Exec['install_pip'],
}

# Install mkdocs and plugins
exec { 'install_mkdocs_and_plugins':
command => '"C:\\Python311\\Scripts\\pip.exe" install --upgrade mkdocs mkdocs-excluder-plugin mkdocs-material',
unless=> '"C:\\Python311\\Scripts\\pip.exe" show mkdocs',
require => Exec['install_pip'],
}

# Install cx_Freeze
exec { 'install_cx_freeze':
command => '"C:\\Python311\\Scripts\\pip.exe" install --upgrade cx-Freeze',
unless=> '"C:\\Python311\\Scripts\\pip.exe" show cx_Freeze',
require => Exec['install_pip'],
}

#more than whats in ps1 script:

#add cze and eng keyboard layout
exec { 'set_keyboard_layouts':
command => 'powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "Set-WinUserLanguageList -LanguageList en-US, cs-CZ -Force"',
unless=> 'powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "$layouts = (Get-WinUserLanguageList).LanguageTag; ($layouts -contains \'en-US\') -and ($layouts -contains \'cs-CZ\')"',
provider=> 'powershell',
}

# Install VS Code
package { 'vscode':
ensure => installed,
provider => 'chocolatey',
}

# Install Google Chrome
package { 'googlechrome':
ensure => installed,
provider => 'chocolatey',
}

#install discord
package { 'Discord':
ensure => 'installed',
provider => 'chocolatey',
}

}
