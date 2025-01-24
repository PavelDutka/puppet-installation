class products {
  # configuration for products team
  file { 'c:\\Temp\\products.txt':
      ensure   => present,
      content  => 'products team'
  }
}
