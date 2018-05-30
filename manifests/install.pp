# @api private
# Install ipmitools
class bmc::install() inherits bmc {

  package { $::bmc::ipmi_packages:
    ensure => $::bmc::ensure,
  }
}