#Class: bmc
#
# Parameters:
# ensure:
# manage_repo:
# manage_idrac:
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage: look at README.md
#
class bmc (
  $ensure      = 'present',
  $manage_repo = true,
  $manage_idrac = $bmc::params::manage_idrac
) inherits bmc::params {

  if $ensure == 'present' or $ensure == 'latest' {
    Class['bmc::validate'] ->
      Class['bmc::install'] ->
      Class['bmc::config'] ->
      Class['bmc::oem']
  } elsif $ensure == 'purged' or $ensure == 'absent' {
    Class['bmc::validate'] ->
      Class['bmc::oem'] ->
      Class['bmc::config'] ->
      Class['bmc::install']
  }

  contain 'bmc::validate'
  contain 'bmc::install'
  contain 'bmc::config'
  contain 'bmc::oem'
}