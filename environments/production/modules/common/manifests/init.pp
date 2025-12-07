class common {
  # configuration for all computers
  file { 'c://Temp//common.txt':
      ensure   => present,
      content  => 'this node does not match certname convention'
  }
}
