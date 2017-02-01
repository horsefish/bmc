class bmc::params () {

  case $manufactor_id {
    # Dell inc.
    '674': { $manage_idrac = true }
    default: { $manage_idrac = false }
  }

  case $::osfamily {
    'Redhat': {
      case $::operatingsystemmajrelease {
        '5', 5: {
          $ipmi_packages = ['OpenIPMI', 'OpenIPMI-tools']
        }
        '6', '7', 6, 7: {
          $ipmi_packages = ['ipmitool']
        }
        default: {
          $ipmi_packages = ['ipmitool']
          warning("Module ${module_name} is not offically supported on redhat ${::operatingsystemmajrelease}
            . Will try to install ${ipmi_package}")
        }
      }
    }
    'Debian': {
      $ipmi_packages = ['ipmitool']
    }
    default: {
      fail("Module ${module_name} is not supported on ${::osfamily}")
    }
  }
}