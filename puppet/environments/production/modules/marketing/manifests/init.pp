class products {
  # configuration for marketing team
  file { 'c:\\Temp\\marketing.txt':
      ensure   => present,
      content  => 'marketing team'
  }
}
