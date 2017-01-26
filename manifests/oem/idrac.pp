class bmc::oem::idrac inherits bmc {
  if $manage_repo {
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
          before   => Class['apt::update']
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