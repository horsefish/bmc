# @api private
# Install ipmitools
class bmc::install () inherits bmc {

  if $::bmc::oem_software {
    if member($::bmc::oem_software, 'dell') { contain '::bmc::oem::omsa' }
    if member($::bmc::oem_software, 'ipmi') { contain '::bmc::oem::ipmi' }
  }
}

