# Baseboard Management Controller module

[IPMItool]: https://sourceforge.net/projects/ipmitool/
[stdmod]: https://github.com/stdmod/
[stdlib module]: https://github.com/puppetlabs/puppetlabs-stdlib
[apt module]: https://forge.puppet.com/puppetlabs/apt
[racadm]: http://pilot.search.dell.com/racadm

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Setup requirements](#setup-requirements)
4. [Usage](#usage)
5. [Operating Systems Support](#operating-systems-support)
6. [Development](#development)

##Overview

This module configures the Remote Management System (Baseboard Management Controller) on Enterprise servers. 

##Module Description

You can configure the BMC's LAN, LDAP and SSL certificates and manage the local users.

It use [IPMItool] or a server provider specific tool (ie. [racadm]) to do the actual communication with the BMC.

The module is based on **stdmod** naming standards version 0.9.0.

Refer to [stdmod] for complete documentation on the common parameters.

##Setup

**What this module affects:**
This module affect's configures the BMC controller.
**WARNING** You 

###Setup Requirements
* PuppetLabs [stdlib module]
* PuppetLabs [apt module]
* Puppet version >= 2.7.x
* Facter version >= 1.6.2

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
    bmc_server_host  => '192.168.0.2'
  }
```

A normal setup would be
```
  bmc_user { 'root':
    password => 'mypassword'
  }
  
  bmc_ssl { 'IDRAC ssl':
    certificate_file => '/etc/ssl/private/idrac.pem',
    certificate_key  => '/etc/ssl/private/idrac.key',
    password         => 'mypassword',
    require          => Bmc_user['root']
  }
```

To configure the NIC to use DHCP
```
  bmc_network { 'bmc_network':
  }
```

To configure a static NIC setup
```
  bmc_network { 'bmc_network':
    ipsrc   => static,
    ipaddr  => '192.168.0.2',
    gateway => '10.235.70.254',
    netmask => '255.255.255.0'
  }
```

if bmc_server_host is not set it ask ipmitool lan print
It only support racadm7

To configure LDAP
```
  bmc_ldap{'iDrac_ldap' :
    server          => 'ldap.example.com',
    base_dn         => 'CN=users,CN=accounts,DC=example,DC=com',
    password        => 'mypassword'
  }
```

##Operating Systems Support

This is tested on these OS:
- Ubuntu 14.04

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
