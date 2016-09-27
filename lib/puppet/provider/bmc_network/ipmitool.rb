Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine :operationsystem => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Adminstrates network on BMC interface"

  commands :ipmitool => "ipmitool"

  def exits?
    #TODO examine if this can be done with ipmitool lan get XXX
    lan_info = Hash.new
    ipmitool_out = ipmitool('lan', 'print', resource[:channel])
    ipmitool_out.split("\n").each do |line|
      case line.split(':')[0]
        when /IP Address Source/
          if line.split(':')[1] =~ /[Ss]tatic/
            lan_info['proto'] = 'static'
          else
            lan_info['proto'] = line.split(':')[1]
          end
        when /IP Address/
          if line.split(':')[1] =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
            lan_info['ipaddr'] = line.split(':')[1].strip
          end
        when /Subnet Mask/
          lan_info['subnet'] = line.split(':')[1].strip
        when /Default Gateway IP/
          lan_info['gateway'] = line.split(':')[1].strip
      end
    end
    unless resource[:proto] == "static"
      true
    else
      if resource[:ipaddr] == lan_info['ipaddr'] &&
          resource[:gateway] == lan_info['gateway'] &&
          resource[:subnet] == lan_info['subnet']
        true
      else
        false
      end
    end
  end

  def destroy
    #Is there a way to clear network config? Otherwise it should not be ensurable!
    true
  end

  def create
    ipmitool('lan', 'set', '1', 'ipaddr', resource[:ipaddr])
    ipmitool('lan', 'set', '1', 'netmask', resource[:subnet])
    ipmitool('lan', 'set', '1', 'gateway', resource[:gateway])
    ipmitool('lan', 'set', '1', 'ipsrc', resource[:type])
  end
end
