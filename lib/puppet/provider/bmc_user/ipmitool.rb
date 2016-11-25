Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine :osfamily => [:redhat, :debian]
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
            'id' => line_array[0],
            'name' => line_array[1],
            'calling' => line_array[2],
            'link_auth' => line_array[3],
            'ipmi_msg' => line_array[4],
            'channel_priv_limit' => line_array[5]
        }
      end
    end
    debug user
    user
  end

  def exists?
    user = get_user_info()
    user[resource[:name]]
  end

  def destroy
    #We can't delete at user, so it is disabled and renamed to xxxxxx. Its renamed because otherwise the exits?
    #would resturn true. Is there a way to detect if user is enabled or disabled? Maybe with a RAW command?
    user = get_user_info()
    ipmitool('user', 'disable', user[resource[:name]]['id'])
    ipmitool('user', 'set', 'name', user[resource[:name]]['id'], 'xxxxxx')
  end

  def create
    #Enabling the user in case it was diabled.
    user = get_user_info()
    ipmitool('user', 'set', 'name', resource[:userid], resource[:name])
  end

  def privilege
    user = get_user_info()
    debug "current priv: #{user['channel_priv_limit']}"
    user['channel_priv_limit']
  end

  def privilege=(value)
    ipmitool('channel', 'setaccess', resource[:channel], resource[:userid], "privilege=#{value}")
  end

  def password
    user = get_user_info()
    debug "current password (tobe removed): #{user['password']}"
    user['password']
  end

  def password=(value)
    #Running as exec so password isn't logged during puppet debug run.
    unless system("ipmitool user set password #{resource[:userid]} #{value}")
      raise Puppet::Error, "Failed to set password for #{resource[:name]}"
    end
  end

  def enable
    user = get_user_info()
    debug "current enabled: #{user['channel_priv_limit']}"
    user['channel_priv_limit']
  end

  def enable=(value)
    ipmitool('user', 'enable', value)
  end
end
