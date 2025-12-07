class bazel_setup {

  $script_source = 'puppet:///modules/bazel_setup/setup-bazel.ps1'
  $script_path   = 'C:/temp/setup-bazel.ps1'

  file { $script_path:
    ensure => file,
    source => $script_source,
  }

  exec { 'run_bazel_setup_script':
    command   => "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy Bypass -File ${script_path}",
    provider  => 'powershell',
    require   => File[$script_path],
    logoutput => true,
  }
}
