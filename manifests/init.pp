class bmc(
  $ensure      = 'present',
  $running     = 'running',
  $manage_repo = false
) inherits bmc::params {

  if $ensure == 'present' or $ensure == 'latest' {
    Class['bmc::validate'] ->
    Class['bmc::install'] ->
    Class['bmc::config'] ~>
    Class['bmc::service'] ->
    Class['bmc::oem']
  } elsif $ensure == 'purged' or $ensure == 'absent' {
    Class['bmc::validate'] ->
    Class['bmc::oem'] ->
    Class['bmc::service'] ->
    Class['bmc::config'] ->
    Class['bmc::install']
  }

  contain 'bmc::validate'
  contain 'bmc::install'
  contain 'bmc::config'
  contain 'bmc::service'
  contain 'bmc::oem'
}