class projects {
  # configuration for projects team
    file { 'c://Temp//projects.txt':
      ensure   => present,
      content  => 'projects team'
  }
}
