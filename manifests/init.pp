#Class: bmc
#
# Baseboard Management Controller
#
# Parameters:
#
# ensure: Control the existences of this bmc module.
# manage_oem_repo: Should 3rd party OEM repositry be managed.
# oem_software: What 3rd party OEM should be installed.
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage: look at README.md
#
class bmc (
  Enum['present', 'absent', 'purged', 'latest']$ensure,
  Boolean $manage_oem_repo,
  Optional[Array[Enum['dell', 'ipmi']]] $oem_software,
) {

  if $ensure == 'present' or $ensure == 'latest' {
    Class['bmc::install']
    -> Class['bmc::config']
  } elsif $ensure == 'purged' or $ensure == 'absent' {
    Class['bmc::config']
    -> Class['bmc::install']
  }

  contain 'bmc::install'
  contain 'bmc::config'
}