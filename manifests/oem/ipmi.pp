# @api private
# Install ipmitool
#
# Parameters:
#
# ensure: If you need a specific version of ipmi.
# packages: The packages needed by ipmitolls.
#
class bmc::oem::ipmi (
  Optional[String] $ensure,
  Array[String] $packages,
) inherits bmc {

  if $ensure {
    $_ensure = $ensure
  } else {
    $_ensure = $::bmc::ensure
  }
  package { $packages:
    ensure => $_ensure,
  }
}