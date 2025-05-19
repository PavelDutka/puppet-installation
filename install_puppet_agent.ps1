#run "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine" to run this script
#this script will guide you through puppet agent setup

# check admin
function Test-IsAdmin {
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as admin, relaunch with elevation
if (-not (Test-IsAdmin)) {
Write-Host "This script requires administrative privileges. Please allow the prompt."
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
exit
}

# Define Variables
$puppetInstallerUrl = "https://downloads.puppetlabs.com/windows/puppet7/puppet-agent-x64-latest.msi"
$puppetConfPath = "C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf"
$puppetServer = "serverus"
$puppetInstallerPath = "C:\temp\puppet-agent-x64.msi"

# Check and create temp directory if it doesn't exist
if (-Not (Test-Path "C:\temp")) {
Write-Host "Creating temp directory..."
New-Item -Path "C:\temp" -ItemType Directory
}

#Ask for team selection using numbers
Write-Host "Select your team by entering the corresponding number:"
Write-Host "1. Projects"
Write-Host "2. Products"
Write-Host "3. Code"
Write-Host "4. Marketing"
$teamSelection = Read-Host -Prompt "Enter number (1-4)"

# Map the team number to the team name
switch ($teamSelection) {
1 { $teamName = "projects" }
2 { $teamName = "products" }
3 { $teamName = "code" }
4 { $teamName = "marketing" }
default {
Write-Host "Invalid selection. Exiting..."
exit
}
}

# Ask for hardware name
$hardwareName = Read-Host -Prompt "Enter pc name (e.g. aquarium, pavel, martin)"

# Ask for usage type
Write-Host "Select the usage type for this computer:"
Write-Host "1. Personal"
Write-Host "2. Polygoniq"
$usageSelection = Read-Host -Prompt "Enter number (1-2)"

# Map the usage selection
switch ($usageSelection) {
1 { $usageType = "personal" }
2 { $usageType = "polygoniq" }
default { 
Write-Host "Invalid selection. Exiting..."
exit
}
}

# Construct certname
$certname = "$teamName-$hardwareName-$usageType"

# Print certname
Write-Host "Generated certname: $certname"

#Download Puppet Agent Installer
try {
Write-Host "Downloading Puppet agent..."
Invoke-WebRequest -Uri $puppetInstallerUrl -OutFile $puppetInstallerPath -ErrorAction Stop
} catch {
Write-Host "Error downloading Puppet agent: $_"
exit
}

#Install Puppet Agent
try {
Write-Host "Installing Puppet agent..."
Start-Process msiexec.exe -ArgumentList "/i $puppetInstallerPath /quiet /norestart" -Wait -ErrorAction Stop
} catch {
Write-Host "Error installing Puppet agent: $_"
exit
}

#Update puppet.conf with certname and server info
Write-Host "Configuring Puppet agent..."
if (-Not (Test-Path $puppetConfPath)) {
Write-Host "puppet.conf not found, creating new configuration..."
New-Item -Path $puppetConfPath -ItemType File -Force
}

# Write certname, server, and environment to puppet.conf
Set-Content -Path $puppetConfPath -Value @"
[main]
certname = $certname
server = $puppetServer
environment = production
runinterval = 24h
"@

#Start Puppet Service
try {
Write-Host "Starting Puppet service..."
Start-Service puppet -ErrorAction Stop
} catch {
Write-Host "Error starting Puppet service: $_"
exit
}

#Ensure Puppet Service Starts Automatically on Boot
try {
Write-Host "Setting Puppet service to start automatically on boot..."
Set-Service puppet -StartupType Automatic -ErrorAction Stop
} catch {
Write-Host "Error setting Puppet service to start automatically: $_"
exit
}

#Update the PATH variable for the current session
$puppetPath = "C:\Program Files\Puppet Labs\Puppet\bin"
if ($env:PATH -notcontains $puppetPath) {
Write-Host "Updating PATH for the current session..."
$env:PATH += ";$puppetPath"
}

# Trigger Puppet agent to request a certificate
try {
Write-Host "Triggering Puppet agent run to request certificate..."
Start-Process puppet -ArgumentList "agent", "-t" -Wait -ErrorAction Stop
} catch {
Write-Host "Error triggering Puppet agent: $_"
exit
}

Write-Host "Puppet agent installed and configured with certname: $certname"
