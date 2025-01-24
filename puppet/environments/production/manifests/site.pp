# Assign teams to their specific configurations
node /^projects/ {
  include projects
}

node /^products/ {
  include products
}

node /^code/ {
  include code
}

node /^marketing/ {
  include marketing
}

node /^projects-vasek/ {
  include home_office
}

node /^products-filip/ {
  include home_office
}

#if doesnt match any cert name
node default {
  include common::config
}
