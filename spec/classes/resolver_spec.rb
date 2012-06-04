require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'resolver' do

  let(:title) { 'resolver' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42', :domain => 'test.dom' } }

  describe 'Test standard installation' do
    it { should contain_file('resolv.conf').with_ensure('present') }
    it 'should not touch existing file' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should be_nil
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:source]
      content.should be_nil
    end
  end

  describe 'Test standard installation with monitoring and firewalling' do
    let(:params) { {:monitor => true , :firewall => true } }

    it { should contain_file('resolv.conf').with_ensure('present') }
    it 'should place a firewall rule' do
      content = catalogue.resource('firewall', 'resolver_udp_53').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test with default domain' do
    let(:params) { { :dns_servers => ['nameserver1', 'nameserver2'] } }

    it { should contain_file('resolv.conf').with_ensure('present') }
    it 'should generate a valid template' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should match "domain test.dom"
      content.should match "nameserver nameserver1"
      content.should match "nameserver nameserver2"
      content.should_not match "sortlist"
      content.should_not match "options"
    end
    it 'should not request a source' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:source]
      content.should be_nil
    end
  end

  describe 'Test parameters as arrays' do
    let(:params) { {:dns_domain => 'the_domain', :search => ['search1', 'search2'], :dns_servers => ['nameserver1', 'nameserver2'], :sortlist => ['sort1', 'sort2'] } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should match "domain the_domain"
      content.should match "search search1 search2"
      content.should match "nameserver nameserver1"
      content.should match "nameserver nameserver2"
      content.should match "sortlist sort1 sort2"
      content.should_not match "options"
    end
    it 'should not request a source' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:source]
      content.should be_nil
    end
  end

  describe 'Test parameters as strings' do
    let(:params) { {:dns_domain => 'the_domain', :search => 'search1,search2', :dns_servers => 'nameserver1,nameserver2', :sortlist => 'sort1,sort2' } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should match "domain the_domain"
      content.should match "search search1 search2"
      content.should match "nameserver nameserver1"
      content.should match "nameserver nameserver2"
      content.should match "sortlist sort1 sort2"
      content.should_not match "options"
    end
    it 'should not request a source' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:source]
      content.should be_nil
    end
  end

  describe 'Test options' do
    let(:params) { {:dns_domain => 'the_domain', :dns_servers => 'server1', :options => { 'opt_a' => 'value_a', 'opt_b' => 'value_b', 'opt_c' => '' } } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should match "domain the_domain"
      content.should match "nameserver server1"
      content.should match "options opt_a:value_a"
      content.should match "options opt_b:value_b"
      content.should match "options opt_c"
      content.should_not match "search"
      content.should_not match "sortlist"
    end
    it 'should not request a source' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:source]
      content.should be_nil
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
    it 'should not request a source' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:source]
      content.should be_nil
    end
  end

  describe 'Test customizations - source' do
    let(:params) { { :source => "puppet://modules/resolver/spec" } }

    it 'should request a valid source' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:source]
      content.should == "puppet://modules/resolver/spec"
    end
    it 'should not build template' do
      content = catalogue.resource('file', 'resolv.conf').send(:parameters)[:content]
      content.should be_nil
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
