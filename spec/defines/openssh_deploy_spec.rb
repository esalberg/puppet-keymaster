require 'spec_helper'
require 'fileutils'
describe 'keymaster::openssh::key::deploy', :type => :define do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
      }
    end
    # before do
    #   key_path  = File.expand_path '/var/lib/keymaster/openssh/tester_at_test.example.org/key'
    #   key_dir   = File.dirname(key_path)
    #   tokens = key_dir.split('/')
    #   1.upto(tokens.size) do |n|
    #     dir = tokens[0..n].join('/')
    #     Dir.mkdir(dir) unless File.directory?(dir)
    #   end
    #   File.open(key_path, 'w'){|f| f.write("-----BEGIN RSA PRIVATE KEY-----\nTHISISAFAKERSAHASH\n-----END RSA PRIVATE KEY-----")}
    #   File.open("#{key_path}.pub", 'w'){|f| f.write('ssh-rsa THISISAFAKERSAHASH foo@baa')}
    # end
    describe 'with default keymaster' do
      let :pre_condition do
        "include keymaster\nuser{'tester': home => '/home/tester', gid => 'tester'}"
      end
      describe 'with minumum parameters' do
        let :title do
          'tester@test.example.org'
        end
        let :params do
          {
            :user     => 'tester',
            :filename => 'id_rsa'
          }
        end
        it { should contain_file('/home/tester/.ssh').with(
          'ensure' => 'directory',
          'owner'  => 'tester',
          'group'  => 'tester',
          'mode'   => '0700'
        ) }
        it { should contain_file('/home/tester/.ssh/id_rsa').with(
          'ensure'  => 'file',
          'owner'   => 'tester',
          'group'   => 'tester',
          'mode'    => '0600',
          'content' => "-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----\n",
          'require' => 'File[/home/tester/.ssh]'
        ) }
        it { should contain_file('/home/tester/.ssh/id_rsa.pub').with(
          'ensure'  => 'file',
          'owner'   => 'tester',
          'group'   => 'tester',
          'mode'    => '0644',
          'content' => "ssh-rsa THISISAFAKERSAHASH tester@test.example.org\n",
          'require' => 'File[/home/tester/.ssh]'
        ) }
      end
      describe 'when ensure is absent' do
        let :title do
          'tester@test.example.org'
        end
        let :params do
          {
            :ensure   => 'absent',
            :user     => 'tester',
            :filename => 'id_rsa'
          }
        end
        it { should contain_file('/home/tester/.ssh/id_rsa').with_ensure('absent') }
        it { should contain_file('/home/tester/.ssh/id_rsa.pub').with_ensure('absent') }
      end
      describe 'when key source files not present' do
        let :title do
          'toaster@some.other.org'
        end
        let :params do
          {
            :user     => 'tester',
            :filename => 'id_rsa'
          }
        end
        it { should raise_error(Puppet::Error, /Private key file \/var\/lib\/keymaster\/openssh\/toaster_at_some.other.org\/key for key toaster@some.other.org not found on keymaster./) }
      end
    end
  end
end
