require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'resolver' do

  let(:title) { 'resolver' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' } }

  describe 'Test standard installation' do
    it { should contain_file('resolv.conf').with_ensure('present') }
  end

  describe 'Test standard installation with monitoring and firewalling' do
    let(:params) { {:monitor => true , :firewall => true } }

    it { should contain_file('resolv.conf').with_ensure('present') }
    it 'should place a firewall rule' do
      content = catalogue.resource('firewall', 'resolver_udp_53').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test customizations - template' do
    let(:params) { {:template => "resolver/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
    it 'should generate a template that uses custom options' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should match "value_a"
    end

  end

  describe 'Test customizations - source' do
    let(:params) { { :source => "puppet://modules/resolver/spec" } }

    it 'should request a valid source ' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:source]
      content.should == "puppet://modules/resolver/spec"
    end
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "resolver::spec" } }
    it 'should automatically include a custom class' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
  end

  describe 'Test Puppi Integration' do
    let(:params) { {:puppi => true, :puppi_helper => "myhelper"} }

    it 'should generate a puppi::ze define' do
      content = catalogue.resource('puppi::ze', 'resolver').send(:parameters)[:helper]
      content.should == "myhelper"
    end
  end

end
