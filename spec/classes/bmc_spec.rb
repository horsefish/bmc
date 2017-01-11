#!/usr/bin/env rspec
require 'spec_helper'

describe "bmc", :type => :class do
  let :facts do
    {
        osfamily: osfamily,
        operatingsystemmajrelease: operatingsystemmajrelease,
        :manufactor_id => '674',
        :lsbdistid => '14.04',
        :lsbdistcodename => 'trusty'
    }
  end
  let(:osfamily) { 'Debian' }
  let(:operatingsystemmajrelease) { 5 }

  context "on debian it is expected to compile" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('ipmitool').with( {:ensure => :present} ) }
  end
  context "On RedHat it is expected to compile" do
    let(:osfamily) { 'Redhat' }
    it { is_expected.to compile.with_all_deps }

    context "On Redhat 5 it should contain OpenIPMI and OpenIPMI-tools" do
      it { is_expected.to contain_package('OpenIPMI').with( {:ensure => :present} ) }
      it { is_expected.to contain_package('OpenIPMI-tools').with( {:ensure => :present} ) }
    end

    context "On Redhat 6 and 7 it should contain ipmitool" do
      [6, 7].each do |operatingsystemrelease|
        let(:operatingsystemmajrelease) { operatingsystemrelease }
        it { is_expected.to contain_package('ipmitool').with( {:ensure => :present} ) }
      end
    end
  end

  context "On Dell servcers it should install racadm" do
    let(:params) { {:manage_repo => true} }
    it { is_expected.to contain_package('srvadmin-all').with( {:ensure => 'present'} ) }
  end
end




