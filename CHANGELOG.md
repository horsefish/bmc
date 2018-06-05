All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## Supported Release 0.1.0
### Summary
Made change to init arguments so we dont need to change API when we add support for more BMC's
### Changed
* bmc
    - change parameter name to manage_oem_repo because it more informativ.
    - change parameter name and type to oem_software of type Array to better support remote setup.

## Supported Release 0.0.4
### Summary
Module is now PDK complient
* bmc_user
    - better support for channels in bmc_user ipmi provider.

## Supported Release 0.0.3
### Summary
Puppet4 data types used.
### Added
* bmc_user
    - general support for enable/disable user.

## Supported Release 0.0.2
### Added
* bmc_user
    - support for enable/disable when using racadm provider
* bmc_network
    - support for more API calls exposed by racadm
    - performance improvments
* other
    - more robust manufactor_id fact
### Removed    
* bmc_network
    - removed defaultto from most property

## Supported Release 0.0.1
### Summary
Still under heavy development and **NO** API are frozen - so use with caution

### Added
* support for bmc_user
* support for bmc_network
* support for bmc_ssl
* support for bmc_ldap
* support for ldap_groups

### Known issues
All racadm testing has been done with remote command's so it's unsure if local racadm command works.