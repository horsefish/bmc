require 'puppet/util/feature'
#Added ruby gem rest-client as feature for puppet.
Puppet.features.add(:restclient, :libs => %{rest-client})
