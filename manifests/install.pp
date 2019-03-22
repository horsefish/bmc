# @api private
# Install ipmitools
class bmc::install () inherits bmc {

  if $::bmc::oem_software {
    if 'dell' in $::bmc::oem_software { contain '::bmc::oem::omsa' }
    if 'ipmi' in $::bmc::oem_software { contain '::bmc::oem::ipmi' }
  }
}

