# @api private
# Params for BMC variables
class bmc::params () {

  case $facts['os']['family'] {
    'Redhat': {
      case $facts['os']['release']['major'] {
        '5': {
          $ipmi_packages = ['OpenIPMI', 'OpenIPMI-tools']
        }
        '6', '7': {
          $ipmi_packages = ['ipmitool']
        }
        default: {
          fail("Module ${module_name} is not supported on Redhat release ${facts['os']['release']['major']}")
        }
      }
    }
    'Debian': {
      $ipmi_packages = ['ipmitool']
      case $facts['os']['release']['major'] {
        '16.04': {
          $_decription_version = split($facts['os']['distro']['description'], ' ')[1]
          if versioncmp($_decription_version, '16.04.4') >= 0 {
            $_omsa_version = '911'
          } else {
            $_omsa_version = '910'
          }
          $apt_source_location = "http://linux.dell.com/repo/community/openmanage/${_omsa_version}/${::lsbdistcodename}"
          $apt_source_repos = 'main'
        }
        '10.04', '12.04', '14.04': {
          $apt_source_location = 'http://linux.dell.com/repo/community/ubuntu'
          $apt_source_repos = 'openmanage'
        }
        default: {
          fail("Module ${module_name} is not supported on Debian release ${facts['os']['release']['major']}")
        }
      }
    }
    'FreeBSD': {
      $ipmi_packages = ['ipmitool']
    }
    default: {
      fail("Module ${module_name} is not supported on ${facts['os']['family']}")
    }
  }
}
