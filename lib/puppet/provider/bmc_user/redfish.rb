require 'json'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'idrac', 'rest.rb'))

Puppet::Type.type(:bmc_user).provide(:redfish) do
  confine :boardmanufacturer => "Dell Inc."
  defaultfor :boardmanufacturer => "Dell Inc."

  confine :feature => :restclient


end
