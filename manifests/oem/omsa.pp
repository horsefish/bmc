# @api private
# Install OpenManage Server Administrator (OMSA), iDRAC Service Module(iSM) and Deployment Tool Kit (DTK) software
class bmc::oem::omsa inherits bmc {

  require ::bmc::params
  $_yum_repo_file_name = '/etc/yum.repos.d/dell-system-update.repo'
  $_omsa_package = 'srvadmin-all'

  if $::bmc::manage_oem_repo {
    case $::osfamily {
      'Debian': {
        include ::apt

        if $::bmc::ensure == 'purged' {
          $apt_ensure = 'absent'
        } else {
          $apt_ensure = 'present'
        }
        apt::source { 'DellOpenManage':
          ensure   => $apt_ensure,
          comment  => 'Dell OpenManage Ubuntu & Debian Repositories',
          location => $::bmc::params::apt_source_location,
          release  => $::lsbdistcodename,
          repos    => $::bmc::params::apt_source_repos,
          key      => {
            'id'     => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
            'server' => 'pool.sks-keyservers.net',
          },
          include  => {
            'src' => false
          },
          before   => [Class['apt::update'], Package[$_omsa_package]],
        }
      }
      'RedHat': {
        if $::bmc::ensure == 'purged' {
          File { 'DELL system update repo':
            ensure => absent,
            path   => $_yum_repo_file_name,
          }
        } else {
          exec { 'Dell Yum repository':
            command => 'curl -s http://linux.dell.com/repo/hardware/dsu/bootstrap.cgi | bash',
            cwd     => '/tmp',
            creates => $_yum_repo_file_name,
            path    => ['/usr/bin', '/usr/sbin'],
            before  => Package[$_omsa_package],
          }
        }
      }
      default: {
        fail("${module_name} provides no repository information for OSfamily: ${::osfamily}")
      }
    }
  }

  package { $_omsa_package:
    ensure => $::bmc::ensure,
  }
}