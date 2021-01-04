# @api private
# Install OpenManage Server Administrator (OMSA), iDRAC Service Module(iSM) and Deployment Tool Kit (DTK) software
#
# Parameters:
#
# ensure: If you need a specific version of omsa.
class bmc::oem::omsa (
  Optional[String] $ensure,
  Array[String] $packages,
  Optional[String] $apt_repos,
  Optional[String] $apt_source_location,
) inherits bmc {

  if $ensure {
    $_ensure = $ensure
  } else {
    $_ensure = $::bmc::ensure
  }

  if $::bmc::manage_oem_repo {
    case $::osfamily {
      'Debian': {
        include ::apt
        if $facts['os']['release']['major'] == '16.04' {
          $_description_version = split($facts['os']['distro']['description'], ' ')[1]
          if versioncmp($_description_version, '16.04.4') >= 0 {
            $_omsa_version = '911'
          } else {
            $_omsa_version = '910'
          }
          $_apt_location = "http://linux.dell.com/repo/community/openmanage/${_omsa_version}/${::lsbdistcodename}"
        } else {
          $_apt_location = $apt_source_location
        }

        if $::bmc::ensure == 'purged' {
          $apt_ensure = 'absent'
        } else {
          $apt_ensure = 'present'
        }
        apt::source { 'DellOpenManage':
          ensure   => $apt_ensure,
          comment  => 'Dell OpenManage Ubuntu & Debian Repositories',
          location => $_apt_location,
          release  => $::lsbdistcodename,
          repos    => $apt_repos,
          key      => {
            'id'     => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
            'server' => 'pool.sks-keyservers.net',
          },
          include  => {
            'src' => false
          },
          before   => [Class['apt::update'], Package[$packages]],
        }
      }
      'RedHat': {
        $_yum_repo_file_name = '/etc/yum.repos.d/dell-system-update.repo'

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
            before  => Package[$packages],
          }
        }
      }
      default: {
        fail("${module_name} provides no repository information for OSfamily: ${::osfamily}")
      }
    }
  }

  package { $packages:
    ensure => $_ensure,
  }
}