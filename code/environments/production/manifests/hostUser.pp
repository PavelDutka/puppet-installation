class hostUser {

    #create host user
   user { 'host':
   ensure => present,
   password => 'guest',
   groups => 'Administrators'
  }

}
