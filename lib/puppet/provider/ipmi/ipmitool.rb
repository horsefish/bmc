Puppet::Type.type(:ipmi).provide(:ipmitool) do
  confine :operationsystem => [:redhat,:debian]
  defaultfor :osfamily => [:redhat,:debian]

  desc ""
end
