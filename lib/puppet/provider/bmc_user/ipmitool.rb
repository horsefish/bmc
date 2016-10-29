Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine :operationsystem => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Adminstrates user on BMC interface"

  commands :ipmitool => "ipmitool"

  def get_user_info
    user = Hash.new
    ipmitool_out = ipmitool('user', 'list', resource[:channel])
    ipmitool_out.each_line do |line|
      line_array = line.split(' ')
      unless line_array[1].to_s.downcase == 'name'
        user[line_array[1]] = {
            'id'                 => line_array[0],
            'name'               => line_array[1],
            'calling'            => line_array[2],
            'link_auth'          => line_array[3],
            'impi_msg'           => line_array[4],
            'channel_priv_limit' => line_array[5]
        }
      end
    end
    user
  end

  def get_current_value(var)
  user=get_user_info
  debug "current proto: #{user[var]}"
  user[var]
  end

  def exits?
    user = get_user_info
    user[resource[:name]]
  end

  def password
  get_current_value('password')
  end

  def pasword=(value)
    unless system( "ipmitool user set password #{resurce[:userid]} #{value}" )
      raise Puppet::Error, "Failed to set password for #{resouce[:name]}"
    end
    debug "Setting password for user '#{resurce[:userid]}' using comand 'ipmitool user set password #{resurce[:userid]} XXXX'"
  end

  def enable
    #TODO need to do some magic here, inorder to detect if user is enabled or disaled
    false
  end

  def enable=(value)
    ipmitool('user', 'enable', value)
  end

  def user
    get_current_value('user')
  end

  def user=(value)
    ipmitool('user', 'set', 'name', resource[:userid],value )
  end

  def priviliege
    get_current_value('privilege')
  end

  def user=(value)
    ipmitool('channel', 'setaccess', resource[:channel], resource[:userid], "privilege=#{value}")
  end
end
