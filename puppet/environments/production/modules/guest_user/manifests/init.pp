class guest_user{
user {'host':
name=> 'host',
ensure=> present,
groups=> ['Users'],
password=> 'host',
managehome => true,
}
}
