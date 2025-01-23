class home_office { 
    # configuration for home office computers
  file { 'C:\products_config.txt':
    ensure  => file,
    content => "This is the configuration for home office computers\n",
  }
} 
