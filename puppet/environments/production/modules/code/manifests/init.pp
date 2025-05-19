class code {
  # configuration for code team
    file { 'c:\\Temp\\code.txt':
      ensure   => present,
      content  => 'code team'
  }
}
