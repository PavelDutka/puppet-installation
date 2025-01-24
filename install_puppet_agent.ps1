#run "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine" to run this script
#this script will guide you through puppet agent setup

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
$puppetServer = "serverus"  # Replace with your Puppet master FQDN
$puppetInstallerPath = "C:\temp\puppet-agent-x64.msi"

# Check and create temp directory if it doesn't exist
if (-Not (Test-Path "C:\temp")) {
    Write-Host "Creating temp directory..."
    New-Item -Path "C:\temp" -ItemType Directory
}

# Step 1: Ask for team selection using numbers
Write-Host "Select your team by entering the corresponding number:"
Write-Host "1. Projects"
Write-Host "2. Products"
Write-Host "3. Code"
Write-Host "4. Marketing"
Write-Host "5. Home Office"
$teamSelection = Read-Host -Prompt "Enter number (1-5)"

# Map the team number to the team name
switch ($teamSelection) {
    1 { $teamName = "projects" }
    2 { $teamName = "products" }
    3 { $teamName = "code" }
    4 { $teamName = "marketing" }
    5 { $teamName = "home_office" }
    default { 
        Write-Host "Invalid selection. Exiting..."
        exit
    }
}

# Step 2: Ask for hardware name
$hardwareName = Read-Host -Prompt "Enter the hardware name (e.g. alena, adam, martin, hexik)"
$certname = "$teamName-$hardwareName"

# Step 3: Download Puppet Agent Installer
try {
    Write-Host "Downloading Puppet agent..."
    Invoke-WebRequest -Uri $puppetInstallerUrl -OutFile $puppetInstallerPath -ErrorAction Stop
} catch {
    Write-Host "Error downloading Puppet agent: $_"
    exit
}

# Step 4: Install Puppet Agent
try {
    Write-Host "Installing Puppet agent..."
    Start-Process msiexec.exe -ArgumentList "/i $puppetInstallerPath /quiet /norestart" -Wait -ErrorAction Stop
} catch {
    Write-Host "Error installing Puppet agent: $_"
    exit
}

# Step 5: Update puppet.conf with certname and server info
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

# Step 6: Start Puppet Service
try {
    Write-Host "Starting Puppet service..."
    Start-Service puppet -ErrorAction Stop
} catch {
    Write-Host "Error starting Puppet service: $_"
    exit
}

# Step 7: Ensure Puppet Service Starts Automatically on Boot
try {
    Write-Host "Setting Puppet service to start automatically on boot..."
    Set-Service puppet -StartupType Automatic -ErrorAction Stop
} catch {
    Write-Host "Error setting Puppet service to start automatically: $_"
    exit
}

# Step 8: Update the PATH variable for the current session
$puppetPath = "C:\Program Files\Puppet Labs\Puppet\bin"
if ($env:PATH -notcontains $puppetPath) {
    Write-Host "Updating PATH for the current session..."
    $env:PATH += ";$puppetPath"
}

# Step 9: Trigger Puppet agent to request a certificate
# Changed to use the correct arguments without "-E" flag
try {
    Write-Host "Triggering Puppet agent run to request certificate..."
    Start-Process puppet -ArgumentList "agent", "-t" -Wait -ErrorAction Stop
} catch {
    Write-Host "Error triggering Puppet agent: $_"
    exit
}

Write-Host "Puppet agent installed and configured with certname: $certname"
Write-Host "You may now use the Puppet command in this terminal session."
