# @api private
# Install ipmitools
class bmc::install () inherits bmc {

  require ::bmc::params
  if $::bmc::oem_software {
    if member($::bmc::oem_software, 'dell') { contain 'bmc::oem::omsa' }

    if member($::bmc::oem_software, 'ipmi') {
      package { $::bmc::params::ipmi_packages:
        ensure => $::bmc::ensure,
      }
    }
  }
}

