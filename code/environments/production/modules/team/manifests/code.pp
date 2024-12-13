class team::code {
  file { "C:/Users/Public/Desktop/code_team.txt":
    ensure  => "file",
    content => "Welcome to the Code team!",
  }
}
