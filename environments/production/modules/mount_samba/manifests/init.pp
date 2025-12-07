class mount_samba (
  String $drive_letter = lookup('mount_samba::drive_letter'),
  String $share_path   = lookup('mount_samba::share_path'),
  String $username     = lookup('mount_samba::username'),
  String $password     = lookup('mount_samba::password'),
) {

  exec { 'remove_existing_drive':
    command  => "net use ${drive_letter} /delete /y",
    onlyif   => "if (net use | Select-String '${drive_letter}') { exit 0 } else { exit 1 }",
    provider => 'powershell',
  }

  exec { 'map_samba_drive':
    command  => "net use ${drive_letter} '${share_path}' /user:'${username}' '${password}' /persistent:yes",
    unless   => "if (net use | Select-String '${drive_letter}') { exit 0 } else { exit 1 }",
    provider => 'powershell',
    require  => Exec['remove_existing_drive'],
  }

  exec { 'create_samba_mount_task':
    command  => "schtasks /create /tn 'SambaMount' /tr \"net use ${drive_letter} '${share_path}' /user:'${username}' '${password}' /persistent:yes\" /sc onlogon /rl highest /f",
    unless   => "if (schtasks /query /tn 'SambaMount' 2>$null) { exit 0 } else { exit 1 }",
    provider => 'powershell',
    require  => Exec['map_samba_drive'],
  }
}
