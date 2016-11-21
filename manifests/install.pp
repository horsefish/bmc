class bmc::install() inherits bmc {
  package { $bmc::params::ipmi_packages:
    ensure => $ensure,
  }

  if $manage_gems {
    package { 'rest-client':
      ensure   => installed,
      provider => gem,
    }
  }

  # The setup is taken from nexus module. Maybe it should be provided as a class parameter?
  # Pros using file:
  # no need to use a class to get parameters, they can be accessed directly from type/provider.
  # Cons:
  # Increase the complexity and fotprint on server and we still need to install rest-client api anyway.
  # This file should be encrypted.
  file { "puppet redfish rest conf":
    path    => "/etc/puppet/redfish_rest.conf",
    ensure  => file,
    mode    => '0640',
    content => template("${module_name}/redfish_rest.conf.erb"),
  }
}