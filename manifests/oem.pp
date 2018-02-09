# @api private
# Handle the orchestration of oem software
class bmc::oem() inherits bmc {
  if $::bmc::manage_idrac { contain 'bmc::oem::idrac' }
}