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
```
  bmc_user { 'test':
    name => 'test',
    password => 'password',
    userid => 3,
    enable => true,
    privilege => 'ADMINISTRATOR',
    channel => 1,
  }
```
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
