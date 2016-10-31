Puppet::Type.type(:bmc_network).provide(:ipmitool) do
  confine :osfamily => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Adminstrates network on BMC interface"

  commands :ipmitool => "ipmitool"

  def exists?
    begin
      ipmitool('lan', 'print', resource[:channel])
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def get_values
    lan_info = Hash.new
    ipmitool_out = ipmitool('lan', 'print', resource[:channel])
    ipmitool_out.split("\n").each do |line|
      case line.split(':')[0]
        when /IP Address Source/
          case line.split(':')[1]
            when /[Ss]tatic/
              lan_info['proto'] = 'static'
            when /[Dd][Hh][Cc][Pp]/
              lan_info['proto'] = 'dhcp'
            when /[Nn]one/
              lan_info['proto'] = 'none'
            when /[Bb]ios/
              lan_info['proto'] = 'bios'
          end
        when /IP Address/
          if line.split(':')[1] =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
            lan_info['ipaddr'] = line.split(':')[1].strip
          end
        when /Subnet Mask/
          lan_info['netmask'] = line.split(':')[1].strip
        when /Default Gateway IP/
          lan_info['gateway'] = line.split(':')[1].strip
      end
    end
    lan_info
  end

  def proto
    lan_info=get_values
    debug "current proto: #{lan_info['proto']}"
    lan_info['proto']
  end

  def proto=(value)
    ipmitool('lan', 'set', resource[:channel], 'ipsrc', value)
  end

  def ipaddr
    lan_info=get_values
    debug "current ipaddr: #{lan_info['ipaddr']}"
    lan_info['ipaddr']
  end

  def ipaddr=(value)
    ipmitool('lan', 'set', resource[:channel], 'ipaddr', value)
  end

  def gateway
    lan_info=get_values
    debug "current gateway: #{lan_info['gateway']}"
    lan_info['gateway']
  end

  def gateway=(value)
    ipmitool('lan', 'set', resource[:channel], 'defgw', 'ipaddr', value)
  end

  def netmask
    lan_info=get_values
    debug "current netmask: #{lan_info['netmask']}"
    lan_info['netmask']
  end

  def netmask=(value)
    ipmitool('lan', 'set', resource[:channel], 'netmask', value)
  end
end
