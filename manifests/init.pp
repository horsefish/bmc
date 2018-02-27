# = Class: bmc
#
# This module manages the bmc (Baseboard Management Controller)
# and the software needed to control it.
#
# == Parameters:
#
# [*ensure*]
#   Parsed to package and controls the state of the software
#   Default: present
#
# [*manage_repo*]
#   Should the module manged the repositories
#   Default: true
#
# [*manage_idrac*]
#   Should idrac software be installed
#   Default: true if OS is installed on a DELL hardware
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