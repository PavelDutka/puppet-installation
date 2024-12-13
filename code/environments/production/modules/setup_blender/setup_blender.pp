class setup_blender {
  # Get Windows environment variables using facts
  $system_drive = $facts['windows_env']['SYSTEMDRIVE']
  $username = $facts['windows_env']['USERNAME']
  
  # Define the source folder on Puppet server
  $source_folder = 'puppet:///modules/setup_blender/files'
  
  # Construct the path to current user's desktop
  $windows_path = "C:/Users/Public/Desktop/"

  # Ensure the destination directory exists
  file { $windows_path:
    ensure => directory,
    before => File['copy_folder_contents'],
  }

  file { "C:/Users/Public/Desktop/itWorks.txt":
    ensure  => "file",
    content => "Welcome to the Projects team!",
  }

  # Copy the folder contents recursively
  file { 'copy_folder_contents':
    path    => $windows_path,
    source  => $source_folder,
    recurse => true,
    force   => true,
    sourceselect => all,
    mode    => '0755',
    source_permissions => ignore,
  }

  # Log the operation for debugging
  notify { "Copying to ${windows_path}":
    before => File['copy_folder_contents'],
  }
}
