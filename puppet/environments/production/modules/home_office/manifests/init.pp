class home_office {
# configuration for home office computers
file { 'c:\\Temp\\home_office.txt':
ensure => present,
content=> 'home office computer'
}
}
