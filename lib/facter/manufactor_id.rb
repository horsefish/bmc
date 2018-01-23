if Facter::Util::Resolution.which('ipmitool')
  ipmitool_mc_info = Facter::Util::Resolution.exec('ipmitool mc info 2>&1')
  if ipmitool_mc_info.include? 'Manufacturer ID'
    Facter.add(:manufactor_id) do
      has_weight 100
      confine :is_virtual => false
      setcode do
        %r{Manufacturer ID\s*: ([\w\.]+)}.match(ipmitool_mc_info)[1]
      end
    end
  end
end