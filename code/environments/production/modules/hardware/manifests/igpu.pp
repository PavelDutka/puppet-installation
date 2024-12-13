class hardware::igpu {
  file { "C:/Users/Public/Desktop/igpu_info.txt":
    ensure  => "file",
    content => "This machine has an integrated GPU.",
  }
}
