class change_lang {
  # Direct registry modifications for language settings
  registry_key { 'HKLM\System\CurrentControlSet\Control\MUI\Settings':
    ensure => present,
  }

  registry_value { 'HKLM\System\CurrentControlSet\Control\MUI\Settings\PreferredUILanguages':
    ensure => present,
    type   => array,
    data   => ['en-US'],
  }

  # Set various registry entries for language settings
  exec { 'set-language-registry':
    provider => powershell,
    command  => '
      # System MUI settings
      reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\International" /v "PreferredUILanguages" /t REG_MULTI_SZ /d "en-US" /f
      reg add "HKLM\SYSTEM\CurrentControlSet\Control\MUI\UILanguages\en-US" /v "Default" /t REG_SZ /d "1" /f
      
      # User UI settings
      reg add "HKCU\Control Panel\Desktop" /v "PreferredUILanguages" /t REG_MULTI_SZ /d "en-US" /f
      reg add "HKCU\Control Panel\Desktop\MuiCached" /v "MachinePreferredUILanguages" /t REG_MULTI_SZ /d "en-US" /f
      
      # International settings
      reg add "HKCU\Control Panel\International" /v "LocaleName" /t REG_SZ /d "en-US" /f
      reg add "HKCU\Control Panel\International" /v "sLanguage" /t REG_SZ /d "ENU" /f
      reg add "HKCU\Control Panel\International" /v "sCountry" /t REG_SZ /d "United States" /f
      
      # System locale
      reg add "HKLM\SYSTEM\CurrentControlSet\Control\Nls\Language" /v "Default" /t REG_SZ /d "0409" /f
      reg add "HKLM\SYSTEM\CurrentControlSet\Control\Nls\Language" /v "InstallLanguage" /t REG_SZ /d "0409" /f
      
      # Welcome screen and new user settings
      reg add "HKLM\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "ShowAutoCorrection" /t REG_DWORD /d "0" /f
      reg add "HKLM\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "ShowTextPrediction" /t REG_DWORD /d "0" /f
      reg add "HKLM\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "ShowCasing" /t REG_DWORD /d "0" /f
      reg add "HKLM\SOFTWARE\Policies\Microsoft\Control Panel\International" /v "ShowShiftLock" /t REG_DWORD /d "0" /f
    ',
    logoutput => true,
  }

  # Download and force install English language pack
  exec { 'force-language-pack':
    provider => powershell,
    command  => '
      # Enable language pack download
      reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Update" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d "0" /f
      
      # Force install language pack
      $env:SYSTEM_WMIC_LOG = "false"
      Dism /online /Get-Intl
      Dism /online /Set-UILang:en-US
      Dism /online /Set-SystemLocale:en-US
      Dism /online /Set-UserLocale:en-US
      Dism /online /Set-InputLocale:0409:00000409
    ',
    logoutput => true,
  }

  # Create startup script for persistent changes
  file { 'C:/Windows/language_setup.ps1':
    ensure  => present,
    content => '
      Set-WinSystemLocale en-US
      Set-WinUILanguageOverride -Language en-US
      Set-Culture en-US
      $UserLanguageList = New-WinUserLanguageList -Language "en-US"
      Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
    ',
  }

  # Create scheduled task to run at startup
  exec { 'create-startup-task':
    provider => powershell,
    command  => '
      $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\\Windows\\language_setup.ps1"
      $Trigger = New-ScheduledTaskTrigger -AtStartup
      $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
      Register-ScheduledTask -TaskName "PersistLanguageSettings" -Action $Action -Trigger $Trigger -Principal $Principal -Force
    ',
    require => File['C:/Windows/language_setup.ps1'],
  }
}
