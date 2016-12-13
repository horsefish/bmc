# Baseboard Management Controller module
#bmc

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Resources managed by bmc module](#resources-managed-by-bmc-module)
    * [Setup requirements](#setup-requirements)
    * [Beginning with module bmc](#beginning-with-module-bmc)
4. [Usage](#usage)
5. [Operating Systems Support](#operating-systems-support)
6. [Development](#development)

##Overview

This module configures BMC interfaces.

##Module Description

The module is based on **stdmod** naming standards version 0.9.0.

Refer to http://github.com/stdmod/ for complete documentation on the common parameters.


##Setup

###Resources managed by bmc module

###Setup Requirements
* PuppetLabs [stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)
* StdMod [stdmod module](https://github.com/stdmod/stdmod)
* Puppet version >= 2.7.x
* Facter version >= 1.6.2

###Beginning with module BMC

##Usage
To setup a simple bmc_user with username 'simple'   
```
  bmc_user { 'simple':
    password => 'password'
  }
```
A more complex user with username 'More complex'
```
  bmc_user { 'More complex':
    password => 'password',
    callin   => false,
    ipmi => true,
    link => false
  }
```
There is no support for separate rules pr channel for a user.

To change the SSL certificate 
```
  bmc_ssl { 'IDRAC ssl':
    certificate_file => '/etc/ssl/private/idrac.pem',
    certificate_key  => '/etc/ssl/private/idrac.key',
    password         => 'idrac_root_password'
    remote_rac_host  => '192.168.0.2'
  }
```
if remote_rac_host is not set it ask ipmitool lan print
It only support racadm7

##Operating Systems Support

This is tested on these OS:
- RedHat osfamily 6
- Ubuntu 14.04

##Development

Pull requests (PR) and bug reports via GitHub are welcomed.

When submitting PR please follow these quidelines:
- Provide puppet-lint compliant code
- If possible provide rspec tests
- Follow the module style and stdmod naming standards

When submitting bug report please include or link:
- The Puppet code that triggers the error
- The output of facter on the system where you try it
- All the relevant error logs
- Any other information useful to undestand the context
