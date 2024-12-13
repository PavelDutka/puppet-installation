class hardware::gpu {
  file { "C:/Users/Public/Desktop/gpu_info.txt":
    ensure  => "file",
    content => "This machine has a dedicated GPU.",
  }
}
