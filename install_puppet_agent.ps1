# Run "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine" to run this script
# This script will guide you through Puppet agent setup

# Function to check if the script is running as Administrator
function Test-IsAdmin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Relaunch with elevation if not admin
if (-not (Test-IsAdmin)) {
    Write-Host "This script requires administrative privileges. Please allow the prompt."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define variables
$puppetInstallerUrl  = "https://downloads.puppetlabs.com/windows/puppet7/puppet-agent-x64-latest.msi"
$puppetConfPath      = "C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf"
$puppetServer        = "serverus.polygoniq.com"
$puppetInstallerPath = "C:\temp\puppet-agent-x64.msi"

# Create temp directory if needed
if (-not (Test-Path "C:\temp")) {
    Write-Host "Creating temp directory..."
    New-Item -Path "C:\temp" -ItemType Directory
}

# Team selection
do {
    Write-Host "Select your team by entering the corresponding number:"
    Write-Host "1. Projects"
    Write-Host "2. Products"
    Write-Host "3. Code"
    Write-Host "4. Marketing"
    $teamSelection = Read-Host -Prompt "Enter number (1-4)"

    switch ($teamSelection) {
        1 { $teamName = "projects";  $validTeam = $true }
        2 { $teamName = "products";  $validTeam = $true }
        3 { $teamName = "code";      $validTeam = $true }
        4 { $teamName = "marketing"; $validTeam = $true }
        default {
            Write-Host "Invalid selection. Please try again.`n"
            $validTeam = $false
        }
    }
} until ($validTeam)

# Ask for hardware name
$hardwareName = (Read-Host -Prompt "Enter pc name (e.g. aquarium, pavel, martin)").ToLower()

# Usage type selection
do {
    Write-Host "`nSelect the usage type for this computer:"
    Write-Host "1. Personal"
    Write-Host "2. Polygoniq"
    $usageSelection = Read-Host -Prompt "Enter number (1-2)"

    switch ($usageSelection) {
        1 { $usageType = "personal";  $validUsage = $true }
        2 { $usageType = "polygoniq"; $validUsage = $true }
        default {
            Write-Host "Invalid selection. Please try again.`n"
            $validUsage = $false
        }
    }
} until ($validUsage)

# Flamenco worker option
$flamencoInstall = Read-Host -Prompt "Setup this machine as Flamenco Worker for distributed rendering? (y/N)"
$flamencoSuffix = ""
if ($flamencoInstall -eq "y" -or $flamencoInstall -eq "Y") {
    $flamencoSuffix = "_flamenco"
}

# Construct certname
$certname = "$teamName-$hardwareName-$usageType$flamencoSuffix"
Write-Host "`nGenerated certname: $certname"

# Download Puppet agent
try {
    Write-Host "Downloading Puppet agent..."
    Invoke-WebRequest -Uri $puppetInstallerUrl -OutFile $puppetInstallerPath -ErrorAction Stop
} catch {
    Write-Host "Error downloading Puppet agent: $_"
    exit
}

# Install Puppet agent
try {
    Write-Host "Installing Puppet agent..."
    Start-Process msiexec.exe -ArgumentList "/i `"$puppetInstallerPath`" /quiet /norestart" -Wait -ErrorAction Stop
} catch {
    Write-Host "Error installing Puppet agent: $_"
    exit
}

# Update puppet.conf
Write-Host "Configuring Puppet agent..."
if (-not (Test-Path $puppetConfPath)) {
    Write-Host "puppet.conf not found, creating new configuration..."
    New-Item -Path $puppetConfPath -ItemType File -Force
}

Set-Content -Path $puppetConfPath -Value @"
[main]
certname = $certname
server = $puppetServer
environment = production
runinterval = 24h
"@

# Start Puppet service
try {
    Write-Host "Starting Puppet service..."
    Start-Service puppet -ErrorAction Stop
} catch {
    Write-Host "Error starting Puppet service: $_"
    exit
}

# Enable Puppet service on boot
try {
    Write-Host "Setting Puppet service to start automatically on boot..."
    Set-Service puppet -StartupType Automatic -ErrorAction Stop
} catch {
    Write-Host "Error setting Puppet service to start automatically: $_"
    exit
}

# Add Puppet bin directory to PATH for session
$puppetPath = "C:\Program Files\Puppet Labs\Puppet\bin"
if ($env:PATH -notcontains $puppetPath) {
    Write-Host "Updating PATH for the current session..."
    $env:PATH += ";$puppetPath"
}

# Trigger Puppet agent run
try {
    Write-Host "Triggering Puppet agent run to request certificate..."
    Start-Process puppet -ArgumentList "agent", "-t" -Wait -ErrorAction Stop
} catch {
    Write-Host "Error triggering Puppet agent: $_"
    exit
}

Write-Host "`nPuppet agent installed and configured with certname: $certname"
