# check admin
function Test-IsAdmin {
    # Get the current Windows identity
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    # Create a Windows principal object
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    # Check if the user is an administrator
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
$puppetServer = "puppet.yourdomain.com"  # Replace with your Puppet master FQDN
$puppetInstallerPath = "C:\temp\puppet-agent-x64.msi"

# Check and create temp directory if it doesn't exist
if (-Not (Test-Path "C:\temp")) {
    Write-Host "Creating temp directory..."
    New-Item -Path "C:\temp" -ItemType Directory
}

# Step 1: Ask for certname input
$certname = Read-Host -Prompt "Enter the certname (<team-hardware-computer>)"

# Step 2: Download Puppet Agent Installer
try {
    Write-Host "Downloading Puppet agent..."
    Invoke-WebRequest -Uri $puppetInstallerUrl -OutFile $puppetInstallerPath -ErrorAction Stop
} catch {
    Write-Host "Error downloading Puppet agent: $_"
    exit
}

# Step 3: Install Puppet Agent
try {
    Write-Host "Installing Puppet agent..."
    Start-Process msiexec.exe -ArgumentList "/i $puppetInstallerPath /quiet /norestart" -Wait -ErrorAction Stop
} catch {
    Write-Host "Error installing Puppet agent: $_"
    exit
}

# Step 4: Update puppet.conf with certname and server info
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
runinterval = 30m
"@

# Step 5: Start Puppet Service
try {
    Write-Host "Starting Puppet service..."
    Start-Service puppet -ErrorAction Stop
} catch {
    Write-Host "Error starting Puppet service: $_"
    exit
}

# Step 6: Ensure Puppet Service Starts Automatically on Boot
try {
    Write-Host "Setting Puppet service to start automatically on boot..."
    Set-Service puppet -StartupType Automatic -ErrorAction Stop
} catch {
    Write-Host "Error setting Puppet service to start automatically: $_"
    exit
}

# Step 7: Update the PATH variable for the current session
$puppetPath = "C:\Program Files\Puppet Labs\Puppet\bin"
if ($env:PATH -notcontains $puppetPath) {
    Write-Host "Updating PATH for the current session..."
    $env:PATH += ";$puppetPath"
}

# Step 8: Trigger Puppet agent to request a certificate
try {
    Write-Host "Triggering Puppet agent run to request certificate..."
    puppet agent -t -ErrorAction Stop
} catch {
    Write-Host "Error triggering Puppet agent: $_"
    exit
}

Write-Host "Puppet agent installed and configured with certname: $certname"
Write-Host "You may now use the Puppet command in this terminal session."
