# Class: neb0t_motd
#
class neb0t_motd (
  $templates = $neb0t_motd::params::templates,
  $poll_time = $neb0t_motd::params::poll,
  $dynamic_motd = true,
  $issue_template = undef,
  $issue_content = undef,
  $issue_net_template = undef,
  $issue_net_content = undef,
) inherits neb0t_motd::params {

  file { $templates:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
  }

  if $issue_template {
    if $issue_content {
        warning('Both $issue_template and $issue_content parameters passed to motd, ignoring issue_content')
    }
    $_issue_content = template($issue_template)
  } elsif $issue_content {
    $_issue_content = $issue_content
  } else {
    $_issue_content = false
  }

  if $issue_net_template {
    if $issue_net_content {
        warning('Both $issue_net_template and $issue_net_content parameters passed to motd, ignoring issue_net_content')
    }
    $_issue_net_content = template($issue_net_template)
  } elsif $issue_net_content {
    $_issue_net_content = $issue_net_content
  } else {
    $_issue_net_content = false
  }

  File {
    mode => '0644',
  }

  if ($::kernel == 'Linux') or ($::kernel == 'SunOS') {
    file { "${neb0t_motd::params::templates}/${neb0t_motd::params::head}":
      ensure  => file,
      backup  => false,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('neb0t_motd/motd.head.erb'),
    }

    file { "${neb0t_motd::params::templates}/${neb0t_motd::params::tail}":
      ensure  => file,
      backup  => false,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('neb0t_motd/motd.tail.erb'),
    }

    file { '/usr/sbin/update_motd':
      ensure  => file,
      backup  => false,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('neb0t_motd/update_motd.erb'),
    }

    cron { 'generate_motd':
      command => '/usr/sbin/update_motd',
      user    => 'root',
      minute  => "*/${poll_time}",
    }

    if $_issue_content {
      file { '/etc/issue':
        ensure  => file,
        backup  => false,
        content => $_issue_content,
      }
    }

    if $_issue_net_content {
      file { '/etc/issue.net':
        ensure  => file,
        backup  => false,
        content => $_issue_net_content,
      }
    }

    if ($::osfamily == 'Debian') and ($dynamic_motd == false) {
      if $::operatingsystem == 'Debian' and versioncmp($::operatingsystemmajrelease, '7') > 0 {
        $_line_to_remove = 'session    optional     pam_motd.so  motd=/run/motd.dynamic'
      } elsif $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '1.00') > 0 {
        $_line_to_remove = 'session    optional     pam_motd.so  motd=/run/motd.dynamic'
      } else {
        $_line_to_remove = 'session    optional     pam_motd.so  motd=/run/motd.dynamic noupdate'
      }

      file_line { 'dynamic_motd':
        ensure => absent,
        path   => '/etc/pam.d/sshd',
        line   => $_line_to_remove,
      }
    }
  } elsif $::kernel == 'windows' {
    registry_value { 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption':
      ensure => present,
      type   => string,
      data   => 'Message of the day',
    }
    registry_value { 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext':
      ensure => present,
      type   => string,
      data   => template('neb0t_motd/motd.head.erb'),
    }
  }
}
