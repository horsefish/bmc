module Ipmi
  class Ipmitool
    def self.parseLan reply
      parsed = Hash.new
      key = ''
      reply.each_line() do |line|
        lineArray = line.split(':')
        if lineArray[0].strip.empty?
          originalValue = parsed[key]
          if (lineArray.count() == 3 && !originalValue.is_a?(Hash))
            subLineArray = originalValue.split(':')
            subkey = subLineArray.slice!(0).strip
            subvalue = subLineArray.join(":").strip
            parsed.delete(key)
            parsed[key] = Hash[subkey, subvalue]
          elsif (lineArray.count() == 3)
            subkey = lineArray.slice!(1).strip
            subvalue = lineArray.join(":").strip
            parsed[key][subkey] = subvalue
          end
        else
          key = lineArray.slice!(0).strip
          value = lineArray.join(":").strip
          if key == "IP Address Source"
            case value
              when /static/i
                value = 'static'
              when /dhcp/i
                value = 'dhcp'
              when /none/i
                value = 'none'
              when /bios/i
                value = 'bios'
            end
          end
          parsed[key] = value
        end
      end
      parsed
    end

    #can not handle if user has name true or false
    def self.parseUser reply
      users = Array.new
      reply.each_line do |line|
        if (line.start_with?('ID'))
          next
        end
        line.match(
            /(?'id'\d*)\s*(?'name'.*?)\s*(?'callin'true|false)\s*(?'link_auth'true|false)\s*(?'ipmi_msg'true|false)\s*(?'channel_priv_limit'.*)/i) do |match|
          users.push({
                         'id' => match['id'],
                         'name' => match['name'],
                         'callin' => match['callin'],
                         'link_auth' => match['link_auth'],
                         'ipmi_msg' => match['ipmi_msg'],
                         'channel_priv_limit' => match['channel_priv_limit']
                     }
          )
        end
      end
      users
    end
  end
end
