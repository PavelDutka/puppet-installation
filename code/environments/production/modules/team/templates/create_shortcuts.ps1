# Paths to executables
$productsExePath = "C:/Users/Public/Desktop/blender_for_products/blender_for_products.exe"
$projectsExePath = "C:/Users/Public/Desktop/blender_for_projects/blender_for_projects.exe"

# Function to create shortcut and pin to taskbar
function Pin-ToTaskbar {
    param (
        [string]$ExePath
    )

    # Path to the shortcut
    $ShortcutPath = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\" + (Get-Item $ExePath).BaseName + ".lnk"

    # Create the shortcut
    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $ExePath
    $Shortcut.WorkingDirectory = (Get-Item $ExePath).DirectoryName
    $Shortcut.Save()
}

# Pin executables to taskbar
Pin-ToTaskbar -ExePath $productsExePath
Pin-ToTaskbar -ExePath $projectsExePath
