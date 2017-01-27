class bmc::install() inherits bmc {

  package { $bmc::params::ipmi_packages:
    ensure => $ensure
  }
}