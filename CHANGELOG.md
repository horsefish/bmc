All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).
## 0.1.9
### Fixed
- Project_page is now correct (Thanks to Oleg Ginzburg)
- Ipmitool is installed on a different location in FreeBSD
### Summary
- Module is now PDK 1.14.0 compliant

## 0.1.8
### Fixed
- Bmc_user and Bmc_ldap_group: Could not evaluate: wrong number of arguments (0 for 1)
 
## 0.1.7
### Summary
- Module is now PDK 1.13.0 compliant

### Added
- Initial support for Dell Bios configuration. This is work in progress because some of the Bios configuration in some
situations has to be done before a OS is installed and right now it is not clear how this is done best. Eventually this
should also be moved to independent module.

## 0.1.6
### Summary
- Module is now PDK 1.9.0 compliant

### Added
- Support for syslog configuration (Thanks to Xand Meaden)

## 0.1.5
### Summary
- Module is now PDK 1.8.0 compliant

### Fixed
- bmc_user racadm provider id was never set in prefetch 

### Added
- More unit tests
- Support for FreeBSD (Thanks to Eirik Øverby)

### Changed
- Fix typos
- Dropped test running Puppet 3

## Supported Release 0.1.4
### Sumary
- Bugfix release

### Fixed
- BMC ipmitool provider was broken

## Supported Release 0.1.3
### Summary
- Module is now PDK 1.7.1 compliant

### Added
- More versions of Ubuntu is now supported

### Changed
- Fix typos
- Changed data_provider to hiera
- Made installation of ipmitool optional

### Removed
- Fact manufactor_id because it depended on ipmitool

### Fixed
- ensure = absent|purged is now working as intended

## Supported Release 0.1.2
### Summary
- Module is now PDK 1.7.0 compliant

## Supported Release 0.1.1
### Summary
- Module is now PDK 1.6.0 compliant

## Supported Release 0.1.0
### Summary
- Made change to init arguments so we dont need to change API when we add support for more BMC's
- Module is now PDK 1.5.0 compliant

### Changed
- bmc
  - change parameter name to manage_oem_repo because it more informativ.
  - change parameter name and type to oem_software of type Array to better support remote setup.

## Supported Release 0.0.4
### Summary
- Module is now PDK compliant

### Changed
- bmc_user
  - better support for channels in bmc_user ipmi provider.

## Supported Release 0.0.3
### Summary
- Puppet4 data types used.

### Added
- bmc_user
  - general support for enable/disable user.

## Supported Release 0.0.2
### Added
- bmc_user
  - support for enable/disable when using racadm provider
- bmc_network
  - support for more API calls exposed by racadm
  - performance improvments
- other
    - more robust manufactor_id fact
    
### Removed    
* bmc_network
    - removed defaultto from most property

## Supported Release 0.0.1
### Summary

### Added
- support for bmc_user
- support for bmc_network
- support for bmc_ssl
- support for bmc_ldap
- support for ldap_groups

### Known issues
- Still under heavy development and **NO** API are frozen - so use with caution