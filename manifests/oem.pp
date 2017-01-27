class bmc::oem() inherits bmc {

  if str2bool($manage_idrac) { contain 'bmc::oem::idrac' }
}