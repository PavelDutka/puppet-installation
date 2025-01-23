class common {
  # configuration for all computers
  file { 'C:\common_config.txt':
    ensure  => file,
    content => "This is the common configuration for all systems\n",
  }
}