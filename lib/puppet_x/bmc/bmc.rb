module Bmc
  class Bmc
    def self.to_bool value
      return true if value == true || value =~ (/(true|t|yes|y|1)$/i)
      return false if value == false || value.empty? || value =~ (/(false|f|no|n|0)$/i)
      raise ArgumentError.new("invalid value for Boolean: \"#{value}\"")
    end
  end
end