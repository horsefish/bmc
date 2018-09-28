# @api private
# Handle the orchestration of oem software
class bmc::oem() inherits bmc {
  require ::bmc::params
  if member($::bmc::oem_software, 'dell') { contain 'bmc::oem::omsa' }
}