class bmc::service inherits bmc {
  service { 'ipmievd':
    ensure => $running
  }
}