class blender_setup {
  # Ensure Blender directories exist
  file { 'C:/blender_for_products':
    ensure  => directory,
    source  => 'R:/blender_for_products',
    recurse => true,
    purge   => true,
    force   => true,
    max_files => 7000,
  }

  file { 'C:/blender_for_projects':
    ensure  => directory,
    source  => 'R:/blender_for_projects',
    recurse => true,
    purge   => true,
    force   => true,
    max_files => 7000,
  }

  # Create desktop shortcuts
  file_lnk { 'Blender for Products Shortcut':
    file_name     => 'Blender for Products.lnk',
    parent_folder => 'C:/Users/Public/Desktop',
    target_path   => 'C:/blender_for_products/blender_for_products.exe',
    require       => File['C:/blender_for_products'],
  }

  file_lnk { 'Blender for Projects Shortcut':
    file_name     => 'Blender for Projects.lnk',
    parent_folder => 'C:/Users/Public/Desktop',
    target_path   => 'C:/blender_for_projects/blender_for_projects.exe',
    require       => File['C:/blender_for_projects'],
  }
}
