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
  Enum['present', 'absent', 'purged', 'latest']$ensure = 'present',
  Boolean $manage_repo                                 = true,
  Boolean $manage_idrac                                = $bmc::params::manage_idrac,
) inherits bmc::params {

  if $ensure == 'present' or $ensure == 'latest' {
    Class['bmc::install']
    -> Class['bmc::config']
    -> Class['bmc::oem']
  } elsif $ensure == 'purged' or $ensure == 'absent' {
    Class['bmc::oem']
    -> Class['bmc::config']
    -> Class['bmc::install']
  }
  contain 'bmc::install'
  contain 'bmc::config'
  contain 'bmc::oem'
}