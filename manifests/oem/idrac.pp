class bmc::oem::idrac inherits bmc {
  if str2bool($manage_repo) {
    case $::osfamily {
      'Debian': {
        include ::apt

        Class['apt::update'] -> Package['srvadmin-all']
        apt::source { 'DellOpenManage':
          comment  => 'Dell OpenManage Ubuntu & Debian Repositories',
          location => "http://linux.dell.com/repo/community/ubuntu",
          release  => $::lsbdistcodename,
          repos    => 'openmanage',
          key      => {
            'id'     => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
            'server' => 'pool.sks-keyservers.net',
          },
          include  => {
            'src' => false
          },
          before   => [Class['apt::update'], Class['srvadmin-all']]
        }
      }
      'RedHat': {
        exec{'Dell Yum repository':
          command => 'wget -q -O - http://linux.dell.com/repo/hardware/dsu/bootstrap.cgi | bash',
          cwd     => '/tmp',
          creates => '/etc/yum.repos.d/dell-system-update.repo',
          path    => ['/usr/bin', '/usr/sbin'],
          before  => Package['srvadmin-all']
        }
      }
      default: {
        fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
      }
    }
  }

  package { 'srvadmin-all':
    ensure => $ensure
  }
}