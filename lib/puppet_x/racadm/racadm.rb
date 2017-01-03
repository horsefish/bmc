require 'puppet/provider'
require 'open3'

module Racadm
  class Racadm < Puppet::Provider

    #needed by ::commands
    self.initvars

    commands :ipmitool => 'ipmitool'

    def self.racadm_call racadm_args, cmd_args
      cmd = ['/opt/dell/srvadmin/bin/idracadm']
      cmd.push('-u').push(racadm_args[:username]) if racadm_args[:username]
      cmd.push('-p').push(racadm_args[:password]) if racadm_args[:password]
      if racadm_args[:bmc_server_host]
        cmd.push('-r').push(racadm_args[:bmc_server_host])
      else
        ipmitool_out = ipmitool('lan', 'print')
        lan_print = Ipmi::Ipmitool.parseLan(ipmitool_out)
        cmd.push('-r').push(lan_print['IP Address'])
      end

      cmd += cmd_args
      stdout, stderr, status = Open3.capture3(cmd.join(' '))
      nr = cmd.index('-p')
      cmd.fill('<secret>', nr+1, 1) #password is not logged.
      raise(Puppet::Error, "#{cmd.join(' ')} failed with #{stderr}") unless status.success?
      Puppet.debug("#{cmd.join(' ')} executed with stdout: '#{stdout}' stderr: '#{stderr}' status: '#{status}'")
      stdout
    end

    def self.parse_racadm reply
      parsed = Hash.new
      reply.each_line() do |line|
        subLineArray = line.split('=')
        if subLineArray.length > 1
          if line.start_with? '[Key='
            parsed['Key'] = subLineArray[1].strip[0..-2]
          elsif !line.start_with? '!!'
            subkey = subLineArray.slice!(0).strip
            subvalue = subLineArray.join("=").strip
            parsed[subkey] = subvalue
          end
        end
      end
      parsed
    end
  end
end
