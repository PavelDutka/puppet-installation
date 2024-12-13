class team::product {
  file { "C:/Users/Public/Desktop/product_team.txt":
    ensure  => "file",
    content => "Welcome to the Products team!",
  }
}
