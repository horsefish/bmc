require 'spec_helper'

describe 'bmc' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        if os == 'ubuntu-16.04-x86_64'
          os_facts.merge(
            os: {
              family: 'Debian',
              release: { major: '16.04' },
              distro: { description: 'Ubuntu 16.04.5 LTS' },
            },
          )
        else
          os_facts
        end
      end

      it { is_expected.to compile }
    end
  end
end
