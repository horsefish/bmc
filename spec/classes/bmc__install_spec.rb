# #!/usr/bin/env rspec
# #
# require 'spec_helper'
#
# describe "bmc" do
#   context "On a Debian OS with no package name specified" do
#     let :facts do
#       {
#           :osfamily => :debian
#       }
#     end
#
#     it { is_expected.to compile.with_all_deps }
#     it { is_expected.to contain_package('ipmitool').with(
#         {
#             :ensure => :present,
#         }
#     ) }
#   end
#
#   context "On a RedHat OS with no package name specified" do
#     let :facts do
#       {
#           :osfamily => 'RedHat',
#           :operatingsystemmajrelease => 5
#       }
#     end
#
#
#     it { is_expected.to compile.with_all_deps }
#     it { is_expected.to contain_package('OpenIPMI').with(
#         {
#             :ensure => :present,
#         }
#     ) }
#     it { is_expected.to contain_package('OpenIPMI-tools').with(
#         {
#             :ensure => :present,
#         }
#     ) }
#   end
#
# end
