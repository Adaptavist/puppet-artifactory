require 'spec_helper'

base_directory = '/opt'
cust_base_directory = '/tmp'
hosting_user      = 'hosting'
hosting_group     = 'hosting'
host = { 'artifactory::conf' => {} }
conf = {}
soft_nofile = '2048'
hard_nofile = '16384'

describe 'artifactory::dependencies', :type => 'class' do

  context "Should include all dependencies based on operating system for generic avstapp app on Debian" do
    let(:facts){{
      :osfamily => 'Debian',
      :lsbdistid => 'Ubuntu',
      :lsbdistcodename => 'precise',
      :host => host,
    }}
    let(:params){{
      :soft_nofile => soft_nofile,
      :hard_nofile => hard_nofile,
    }}

    it do
      should contain_oracle_java
      should contain_limits__fragment('*/soft/nofile').with(
        'value' => soft_nofile
      )
      should contain_limits__fragment('*/hard/nofile').with(
        'value' => hard_nofile
      )
      should contain_package('libaugeas-ruby').with(
        'ensure' => 'installed',
      )
    end
  end

  context "Should include all dependencies based on operating system for generic avstapp app on RedHat" do
    let(:facts){{
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.5',
      :host => host,
    }}
    let(:params){{
      :soft_nofile => soft_nofile,
      :hard_nofile => hard_nofile,
    }}

    it do
      should contain_oracle_java
      should contain_limits__fragment('*/soft/nofile').with(
        'value' => soft_nofile
      )
      should contain_limits__fragment('*/hard/nofile').with(
        'value' => hard_nofile
      )
      ['apr-util', 'neon', 'augeas'].each do |pack|
        should contain_package(pack).with(
              'ensure' => 'installed',
        )
      end
    end
  end
end
