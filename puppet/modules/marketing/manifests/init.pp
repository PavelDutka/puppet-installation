class products {
  # configuration for marketing team
  file { 'C:\products_config.txt':
    ensure  => file,
    content => "This is the marketing team's configuration\n",
  }
}
