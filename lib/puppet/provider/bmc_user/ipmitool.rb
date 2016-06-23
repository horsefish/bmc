Puppet::Type.type(:bmc_user).provide(:ipmitool) do
  confine :operationsystem => [:redhat,:debian]
  defaultfor :osfamily => [:redhat,:debian]

  desc "Adminstrates user on BMC interface"

  commands :ipmotool => "ipmitool"


  class BMCUser
    def initialize(channelno)
      @channelno = channelno
    end

    def exits
      ipmitool_out = ipmitool('user','list',@channelno)
    end
  end


  def exits?

  end

  def destroy

  end

  def create

  end
end
