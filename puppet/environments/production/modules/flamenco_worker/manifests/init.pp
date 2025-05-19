class flamenco_worker {
  # Ensure the destination directory exists and copy contents
  file { 'C:/flamenco-worker':
    ensure  => directory,
    source  => 'R:/flamenco-setup/flamenco-worker',
    recurse => true,
    purge   => false,
    force   => true,
    backup  => false,
  }

  # Copy startup batch file to Windows Startup folder
  file { 'startup-flamenco-worker-bat':
    path   => 'C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/start-flamenco-worker.bat',
    ensure => file,
    source => 'C:/flamenco-worker/start-flamenco-worker.bat',
    mode   => '0755', # Ensures executable permissions on Windows
    require => File['C:/flamenco-worker'],
  }

  # Execute the Flamenco worker startup batch file
  exec { 'start-flamenco-worker':
    command   => 'C:\Windows\System32\cmd.exe /c start "" "C:/flamenco-worker/start-flamenco-worker.bat"',
    provider => windows,
    unless   => 'C:\Windows\System32\tasklist.exe /FI "IMAGENAME eq start-flamenco-worker.bat"',
    require  => File['startup-flamenco-worker-bat'],
  }
}
