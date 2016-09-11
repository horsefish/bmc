Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine :operationsystem => [:redhat, :debian]
  defaultfor :osfamily => [:redhat, :debian]

  desc "Adminstrates network on BMC interface"

  commands :ipmitool => "ipmitool"

  def exits?
    #ipmitool_out = ipmitool('lan', 'print', resource[:channel])
    #ipmitool_out.each_line do |line|
    #  line_array = line.split(' ')
    #  unless line_array[1].to_s.downcase == 'name'
    #    user[line_array[1]] = {
    #        'id'                 => line_array[0],
    #        'name'               => line_array[1],
    #        'calling'            => line_array[2],
    #        'link_auth'          => line_array[3],
    #        'impi_msg'           => line_array[4],
    #        'channel_priv_limit' => line_array[5]
    #    }
    #  end
    #end
    resource[:ipaddr]
  end

  def destroy

  end

  def create

  end
end
