class flamenco_worker {

  # Ensure the Flamenco Worker directory exists and copy files
  file { 'C:/flamenco-worker':
    ensure    => directory,
    source    => 'R:/flamenco-setup/flamenco-worker',
    recurse   => true,
    purge     => false,
    force     => true,
    backup    => false,
    max_files => 7000,
  }

  # Scheduled task to run Flamenco Worker on login
  scheduled_task { 'Start Flamenco Worker at Login':
    ensure  => present,
    command => 'C:\flamenco-worker\start-flamenco-worker.bat',
    user    => 'SYSTEM',
    trigger => {
      schedule => 'logon',
    },
    require => File['C:/flamenco-worker'],
  }

}
