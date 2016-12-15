module Racadm
  class Racadm

    def self.parseiDRAC_IPv4 reply
      parsed = Hash.new
      reply.each_line() do |line|
        unless line.start_with? '['
          subLineArray = line.split('=')
          if subLineArray.length == 2
            parsed[subLineArray[0]] = subLineArray[1].strip
          end
        end
      end
      parsed
    end
  end
end
