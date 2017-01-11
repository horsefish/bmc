#!/usr/bin/env rspec
#
require 'spec_helper'

describe "bmc", :type => :class do
  context "on debian it is expected to compile" do
  let(:facts) { {
      :osfamily => 'Debian'
  } }
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('ipmitool').with(
      {
          :ensure => :present,
      }
  ) }
  end
  context "On a RedHat it is expected to compile" do
    let :facts do
      {
          :osfamily => 'RedHat',
          :operatingsystemmajrelease => 5
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('OpenIPMI').with(
        {
            :ensure => :present,
        }
    ) }
    it { is_expected.to contain_package('OpenIPMI-tools').with(
        {
            :ensure => :present,
        }
    ) }
  end

end




