class code {
  # configuration for code team
  include chocolatey
    file { 'c://Temp//code.txt':
      ensure   => present,
      content  => 'code team'
  }
    package { 'docker-desktop':
      ensure          => installed,
      provider        => 'chocolatey',
  }
}
