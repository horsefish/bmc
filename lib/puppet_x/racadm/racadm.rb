module Racadm
  class Racadm

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
