# Define the paths for the shortcut files
$blenderForProductsPath = "C:\Users\Public\Desktop\blender_for_products.lnk"
$blenderForProjectsPath = "C:\Users\Public\Desktop\blender_for_projects.lnk"

# Create a shortcut function
function Create-Shortcut {
    param(
        [string]$targetPath,
        [string]$shortcutPath
    )

    # Check if the shortcut already exists
    if (-Not (Test-Path $shortcutPath)) {
        # Create a new WScript.Shell COM object
        $wshShell = New-Object -ComObject WScript.Shell
        $shortcut = $wshShell.CreateShortcut($shortcutPath)
        
        # Set the properties for the shortcut
        $shortcut.TargetPath = $targetPath
        $shortcut.Save()
    }
}

# Create the shortcuts on the desktop
Create-Shortcut -targetPath "C:\setup_scripts\blender_for_products\blender_for_products.exe" -shortcutPath $blenderForProductsPath
Create-Shortcut -targetPath "C:\setup_scripts\blender_for_projects\blender_for_projects.exe" -shortcutPath $blenderForProjectsPath

# Pinning the shortcuts to the taskbar by invoking the pinning task
function Pin-ShortcutToTaskbar {
    param(
        [string]$shortcutPath
    )

    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace('C:\Users\Public\Desktop')
    $item = $folder.ParseName([System.IO.Path]::GetFileName($shortcutPath))

    # If the item exists, pin it to the taskbar
    if ($item -ne $null) {
        $item.InvokeVerb('Pin to Tas&kbar')
    }
}

# Pin the shortcuts to the taskbar
Pin-ShortcutToTaskbar -shortcutPath $blenderForProductsPath
Pin-ShortcutToTaskbar -shortcutPath $blenderForProjectsPath
