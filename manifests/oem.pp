class bmc::oem() {

  # Dell inc.
  if $manufactor_id == '674' {
    contain 'bmc::oem::idrac'
  }
}