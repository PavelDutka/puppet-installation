class team::marketing {
  file { "C:/Users/Public/Desktop/marketing_team.txt":
    ensure  => "file",
    content => "Welcome to the Marketing team!",
  }
}
