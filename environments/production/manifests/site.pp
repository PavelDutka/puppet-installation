# for all computers:
include blender_setup
include prepare_windows_workstation
# include mount_samba # not tested yet
include bazel_setup

# for teams
node /^projects/ {
  include projects
}

node /^_flamenco/ {
  include flamenco_worker
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

node /^._*polygoniq/ {
  include guest_user
}

# if doesnt match any cert name
node default {
  include common
}
