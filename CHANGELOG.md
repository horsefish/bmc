## Supported Release 0.0.2
### Summary
* bmc_user
    - added support for enable/disable when using racadm provider
* bmc_network
    - added support for more API calls exposed by racadm
    - removed defaultto from most property
    - performance improvments

* other
    - more robust manufactor_id fact

## Supported Release 0.0.1
### Summary
Still under heavy development and **NO** API are frozen - so use with caution

#### Features
* Add support for bmc_user
* Add support for bmc_network
* Add support for bmc_ssl
* Add support for bmc_ldap
* Add support for ldap_groups

### Known issues
All racadm testing has been done with remote command's so it's unsure if local racadm command works.