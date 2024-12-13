# Pin a shortcut to the taskbar using the Shell.Application COM object

$blenderForProductsShortcut = "C:\Users\Public\Desktop\blender_for_products.lnk"
$blenderForProjectsShortcut = "C:\Users\Public\Desktop\blender_for_projects.lnk"

# Function to pin a shortcut to the taskbar
function Pin-ShortcutToTaskbar {
    param(
        [string]$shortcutPath
    )
    
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Get-Item $shortcutPath).DirectoryName)
    $file = $folder.ParseName((Get-Item $shortcutPath).Name)
    $file.InvokeVerb("pin to taskbar")
}

# Pin both shortcuts
Pin-ShortcutToTaskbar -shortcutPath $blenderForProductsShortcut
Pin-ShortcutToTaskbar -shortcutPath $blenderForProjectsShortcut
