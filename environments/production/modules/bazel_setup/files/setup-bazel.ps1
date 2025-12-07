go install github.com/bazelbuild/bazelisk@latest
go install github.com/bazelbuild/buildtools/buildifier@latest
$bazel_exe_path = $HOME + "/go/bin/bazel.exe"
# create a hardlink called bazel.exe pointing to bazelisk.exe, this way users can
# just call bazel in the command line and it executes bazelisk as it should
if (Test-Path $bazel_exe_path) {
  Remove-Item $bazel_exe_path
}
New-Item -ItemType HardLink -Path $bazel_exe_path -Target $($HOME + "/go/bin/bazelisk.exe")

# Windows has strict path length limitations and bazel uses long paths to sandbox
# builds. This results in weird issues when building and testing in the repo.
# We can get slightly shorter paths by setting output_base to C:/bz in bazelrc
$bazelrc_path = $HOME + "/.bazelrc"
if (!(Test-Path $bazelrc_path)) {
  $bazelrc_contents  = "# short output base on Windows to avoid running into path length limits`n"
  $bazelrc_contents += "startup --output_base=C:/bz`n"
  $bazelrc_contents += "# use disk cache even though we might be using remote cache, this speeds up rebuilds when switching branches`n"
  $bazelrc_contents += "build --disk_cache=C:/bz_cache`n"
  $bazelrc_contents += "# use repository cache to avoid re-downloads of python packages and other external resources`n"
  $bazelrc_contents += "build --repository_cache=C:/bz_cache/bazel_repository_cache`n"
  $bazelrc_contents | Out-File -Encoding ascii -FilePath $bazelrc_path
}

$bazelautocomplete_file = ".bashrc-bazelautocomplete"
$bazelautocomplete_path = $HOME + "/" + $bazelautocomplete_file


if (!(Test-Path $bazelautocomplete_path)) {
  try {
    # Needed so the bazelisk picks up the correct .bazelversion file
    Set-Location -Path "$HOME/polygoniq"
    $bazelCompletion = bazel help completion

    $version = Get-Content -Path ".bazelversion" -TotalCount 1
    $headerUri = "https://raw.githubusercontent.com/bazelbuild/bazel/$version/scripts/bazel-complete-header.bash"
    $templateUri = "https://raw.githubusercontent.com/bazelbuild/bazel/$version/scripts/bazel-complete-template.bash"
    $headerResponse = Invoke-WebRequest -Uri $headerUri -ErrorAction Stop
    $templateResponse = Invoke-WebRequest -Uri $templateUri -ErrorAction Stop

    $content = $headerResponse.Content + "`n" + $templateResponse.Content + "`n" + $bazelCompletion

    $content | Out-File -Encoding ascii $bazelautocomplete_path

  } catch {
    Write-Host "Bazel auto-completion file was not created due to an error when retriving the scripts or writing the file."
  }
}

# We want some common best practices bash rc settings, especially for history handling
# across multiple shells
$bashrc_path = $HOME + "/.bashrc"
if (!(Test-Path $bashrc_path)) {
  $bashrc_contents  = "# no duplicates`n"
  $bashrc_contents += "HISTCONTROL=ignoredups:erasedups`n"
  $bashrc_contents += "# 100k should be enough for everyone`n"
  $bashrc_contents += "HISTSIZE=100000`n"
  $bashrc_contents += "HISTFILESIZE=100000`n"
  $bashrc_contents += "# When the shell exits, append to the history file instead of overwriting it`n"
  $bashrc_contents += "shopt -s histappend`n"
  $bashrc_contents += "# Append after each command, so history is saved across sessions`n"
  $bashrc_contents += "PROMPT_COMMAND='history -a'`n"
  $bashrc_contents += "# Load autocomplete for bazel if it exists`n"
  $bashrc_contents += "if [ -f ~/$bazelautocomplete_file ]; then`n"
  $bashrc_contents += "    source ~/$bazelautocomplete_file`n"
  $bashrc_contents += "fi`n"
  $bashrc_contents | Out-File -Encoding ascii -FilePath $bashrc_path
}