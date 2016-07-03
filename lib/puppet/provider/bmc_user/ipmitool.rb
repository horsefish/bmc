Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine :operationsystem => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Adminstrates user on BMC interface"

  commands :ipmitool => "ipmitool"


  channelno = channelno
  privilege_lvl = {'callback' => 1, 'user' => 2, 'operator' => 3, 'administrator' => 4}
  user = Hash.new
  ipmitool_out = ipmitool('user', 'list', @channelno)
  ipmitool_out.each_line do |line|
    line_array = line.split(' ')
    unless line_array[1].to_s.downcase == 'name'
      user[line_array[1]] = {
          'id' => line_array[0],
          'name' => line_array[1],
          'calling' => line_array[2],
          'link_auth' => line_array[3],
          'impi_msg' => line_array[4],
          'channel_priv_limit' => line_array[5]}
    end
  end


  def exits?
    #Ipmitool doesn't supprt deleting user so we don't test if user exists, but if user is enabled or disabled.
    user[resource[:name]]['link_auth'] == true
  end

  def destroy
    #We can't delete at user, so it is disabled
    ipmitool('user', 'disable', user[resource[:name]['id']])
  end

  def create
    if user[resource[:name]]
      ipmitool('user', 'enable', user[resource[:name]['id']])
    else
      #Configure user.
      ipmitool()
    end
  end
end
