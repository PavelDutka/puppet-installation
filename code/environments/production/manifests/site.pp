node /^marketing-/ {
  include role::marketing_igpu
}
node /^projects-desktop/ {
  include role::projects_gpu
}
node /^code-/ {
  include role::code_igpu
}
node /^products-/ {
  include role::marketing_igpu
}


node default {
  include setup_environment
  include setup_blender
  include create_user
  include change_lang
}
