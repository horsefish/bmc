#!/usr/bin/env rspec
#
require 'spec_helper'


def load_fix(type, name)
  provider.expects(:ethtool).with("-#{type}", 'eth0').returns(IO.read("#{File.dirname(__FILE__)}/../../fixtures/ethtool_outputs/#{type}/#{name}.txt"))
end