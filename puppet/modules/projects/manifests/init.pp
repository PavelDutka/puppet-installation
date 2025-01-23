class projects {
  # configuration for projects team
  file { 'C:\products_config.txt':
    ensure  => file,
    content => "This is the projects team's configuration\n",
  }
}
