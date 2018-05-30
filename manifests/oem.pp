# @api private
# Handle the orchestration of oem software
class bmc::oem() inherits bmc {
  if member($::bmc::oem_software, 'idrac') { contain 'bmc::oem::idrac' }
}