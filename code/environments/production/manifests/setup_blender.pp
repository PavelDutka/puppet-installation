class setup_blender {
	# Copy blender_for_projects
  file { 'C:/blender_for_projects':
    ensure             => directory,
    source             => 'puppet:///modules/setup_blender/blender_for_projects',
    recurse            => true,
    force              => true,
    sourceselect       => all,
    source_permissions => ignore,
    replace            => true,
  }

  # Copy blender_for_products
  file { 'C:/blender_for_products':
    ensure             => directory,
    source             => 'puppet:///modules/setup_blender/blender_for_products',
    recurse            => true,
    force              => true,
    sourceselect       => all,
    source_permissions => ignore,
    replace            => true,
  }


}
