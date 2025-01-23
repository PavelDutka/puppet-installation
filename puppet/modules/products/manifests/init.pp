class products {
  # configuration for products team
  file { 'C:\products_config.txt':
    ensure  => file,
    content => "This is the products team's configuration\n",
  }
}
