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


  def exits?
    get_user_info
    user[resource[:name]]
  end

  def destroy
    #We can't delete at user, so it is disabled and renamed to xxxxxx. Its renamed because othervise the exixts?
    #would resturn true. Is there a way to detect if user is enabled or disabled? MAybe with a RAW command?
    ipmitool('user', 'disable', user[resource[:name]['id']])
    ipmitool('user', 'set', 'name', user[resource[:name]]['id'], 'xxxxxx')
  end

  def create
    #Enabling the user in case it was diabled.
    ipmitool('user', 'enable', resource[:userid])
    ipmitool('user', 'set', 'name', resource[:userid],resource[:name] )
    #Running as exec so password isn't logged during puppet debug run.
    unless system( "ipmitool user set password #{resurce[:userid]} #{resource[:password]}" )
      raise Puppet::Error, "Failed to set password for #{resouce[:name]}"
    end
    ipmitool('channel', 'setaccess', resource[:channel], resource[:userid], "privilege=#{resource[:privilege]}")
  end
end
