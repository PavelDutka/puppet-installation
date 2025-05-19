class bazel_setup {

# Install Go if it's not already installed
package { 'go':
ensure => installed,
}

# Install Bazelisk if not already installed
exec { 'install_bazelisk':
command => 'go install github.com/bazelbuild/bazelisk@latest',
unless=> "Test-Path \"${env:USERPROFILE}\\go\\bin\\bazelisk.exe\"",
provider=> powershell,
require => Package['go'],
}

# Install Buildifier if not already installed
exec { 'install_buildifier':
command => 'go install github.com/bazelbuild/buildtools/buildifier@latest',
unless=> "Test-Path \"${env:USERPROFILE}\\go\\bin\\buildifier.exe\"",
provider=> powershell,
require => Package['go'],
}

# Create a hardlink for bazel.exe pointing to bazelisk.exe
exec { 'create_hardlink_for_bazel':
command => "New-Item -ItemType HardLink -Path \"${env:USERPROFILE}\\go\\bin\\bazel.exe\" -Target \"${env:USERPROFILE}\\go\\bin\\bazelisk.exe\"",
unless=> "Test-Path \"${env:USERPROFILE}\\go\\bin\\bazel.exe\"",
provider=> powershell,
require => Exec['install_bazelisk'],
}

# Set the bazelrc file path using fully qualified path
$bazelrc_path = "${env:USERPROFILE}\\.bazelrc"

# Create the .bazelrc file with the necessary content
file { 'create_bazelrc':
ensure=> file,
path=> $bazelrc_path,
content => "# short output base on Windows to avoid running into path length limits\nstartup --output_base=C:/bz\n# use disk cache even though we might be using remote cache\nbuild --disk_cache=C:/bz_cache\n# use repository cache to avoid re-downloads\nbuild --repository_cache=C:/bz_cache/bazel_repository_cache\n",
mode=> '0644',
require => Exec['create_hardlink_for_bazel'],
}

# Set the bashrc path for auto-completion
$bashrc_path = "${env:USERPROFILE}\\.bashrc"
$bazelautocomplete_file = ".bashrc-bazelautocomplete"
$bazelautocomplete_path = "${env:USERPROFILE}\\$bazelautocomplete_file"

# Ensure .bashrc has the best practices for history handling and auto-completion setup
file { 'update_bashrc':
ensure=> file,
path=> $bashrc_path,
content => "# no duplicates\nHISTCONTROL=ignoredups:erasedups\n# 100k should be enough for everyone\nHISTSIZE=100000\nHISTFILESIZE=100000\n# When the shell exits, append to the history file instead of overwriting it\nshopt -s histappend\n# Append after each command, so history is saved across sessions\nPROMPT_COMMAND='history -a'\n# Load autocomplete for bazel if it exists\nif [ -f ~/$bazelautocomplete_file ]; then\nsource ~/$bazelautocomplete_file\nfi\n",
mode=> '0644',
require => [ File['create_bazelrc'], Exec['create_hardlink_for_bazel'] ],
}

# Set up Bazel autocomplete file if it doesn't exist
exec { 'create_bazel_autocomplete':
command => "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/bazelbuild/bazel/${version}/scripts/bazel-complete-header.bash' -OutFile '$bazelautocomplete_path'",
unless=> "Test-Path '$bazelautocomplete_path'",
provider=> powershell,
require => File['update_bashrc'],
}
}
