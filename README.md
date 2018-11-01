# Baseboard Management Controller module

[![Build Status](https://api.travis-ci.org/horsefish/bmc.png?branch=master)](https://travis-ci.org/horsefish/bmc)
[![Code Coverage](https://coveralls.io/repos/github/horsefish/bmc/badge.svg?branch=master)](https://coveralls.io/github/horsefish/bmc)

[IPMItool]: https://sourceforge.net/projects/ipmitool/
[stdlib module]: https://github.com/puppetlabs/puppetlabs-stdlib
[apt module]: https://forge.puppet.com/puppetlabs/apt
[racadm]: http://pilot.search.dell.com/racadm

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Requirements](#Setup-Requirements)
    * [Installation](#beginning-with-bmc)
4. [Usage](#usage)
5. [Operating Systems Support](#operating-systems-support)
6. [Development](#development)

## Overview

This module configures the Remote Management System (Baseboard Management Controller) on Enterprise servers. 

##Module Description

You can configure the BMC's LAN, LDAP and SSL certificates and manage the local users.

Can use [IPMItool] require at least version 1.8.18 or a server provider specific tool (ie. [racadm]) to do the actual communication with the BMC.

## Setup

**What this module affects:**
This module affect's configures the BMC controller.

### Setup Requirements
* PuppetLabs [stdlib module]
* PuppetLabs [apt module]
* Puppet version >= 4.0.x
* Facter version >= 2.4.3

###Beginning with bmc
To begin using the bmc module just include the bmc module and it will install ipmitools or 3rd party OEM sofware if it
is on supported hardware.
```puppet
  include bmc
```

If you don't have access to the internet you can manage if 3rd party repositores should be installed. 
```puppet
  class { 'bmc':
    manage_oem_repo => false,
  }
```

##Usage
###Simple user
To setup a bmc_user with username 'simple' with password: password
```puppet
  bmc_user { 'simple':
    password => 'password',
  }
```
###A more complex user
A bmc user that only can use ipmi
```puppet
  bmc_user { 'More complex':
    password => 'password',
    callin   => false,
    ipmi     => true,
    link     => false,
  }
```
###A very complex user
A bmc user with administrator privilege on channel 2 and user privilege on channem 1. 
```puppet
  bmc_user { 'Very complex':
    password  => 'password',
    callin    => false,
    ipmi      => true,
    privilege => 
      {
        '1' => user,
        '2' => administrator,
      }
  }
```
###With access to iDRAC with admin rights
```puppet
  bmc_user { 'idrac_admin':
    password => 'password',
    callin   => true,
    ipmi     => true,
    link     => true,
    idrac    => 0x1ff,
  }
```
*There is no support for separate rules pr channel for a user yet.*
###To change the SSL certificate 
```puppet
  bmc_ssl { 'IDRAC ssl':
    certificate_file => '/etc/ssl/private/idrac.pem',
    certificate_key  => '/etc/ssl/private/idrac.key',
    bmc_username     => 'root',
    bmc_password     => '<idrac_root_password>',
    bmc_server_host  => '192.168.0.2',
  }
```
###A normal setup would be
```puppet
  bmc_user { 'root':
    password => 'mypassword',
  }
  
  bmc_ssl { 'IDRAC ssl':
    certificate_file => '/etc/ssl/private/idrac.pem',
    certificate_key  => '/etc/ssl/private/idrac.key',
    password         => 'mypassword',
    require          => Bmc_user['root'],
  }
```
###To configure the NIC to use DHCP
```puppet
  bmc_network { 'bmc_network':
  }
```
###To configure a static NIC setup
```puppet
  bmc_network { 'bmc_network':
    ipsrc   => static,
    ipaddr  => '192.168.0.2',
    gateway => '10.235.70.254',
    netmask => '255.255.255.0',
  }
```

if bmc_server_host is not set it ask ipmitool lan print
*It only support racadm7*

###To configure LDAP
```puppet
  bmc_ldap{'iDrac_ldap' :
    server  => 'ldap.example.com',
    base_dn => 'CN=users,CN=accounts,DC=example,DC=com',
  }
```
###To configure LDAP groups
```puppet
  bmc_ldap_group{'1' :
    server  => 'ldap.example.com',
    base_dn => 'CN=users,CN=accounts,DC=example,DC=com',
  }
```

##Operating Systems Support

This is tested on these OS:
- Ubuntu 14.04
- Centos 7.4

##Development
To develop (and test) providers we need access to as many and divert BMC's
as possible. So if you have access to a server from HP, Dell, Intel, IBM, Oracle(SUN)
where you will provide us admin rights for both BMC and OS please contact us.

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
