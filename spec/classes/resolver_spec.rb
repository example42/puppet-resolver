require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'resolver' do

  let(:title) { 'resolver' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42', :domain => 'test.dom' } }

  describe 'Test standard installation' do
    it { should contain_file('resolv.conf').with_ensure('file') }
    it 'should not touch existing file' do
      should contain_file('resolv.conf').with_content(nil)
      should contain_file('resolv.conf').with_source(nil)
    end
  end

  describe 'Test standard installation with monitoring and firewalling' do
    let(:params) { {:monitor => true , :firewall => true } }

    it { should contain_file('resolv.conf').with_ensure('file') }
    it 'should place a firewall rule' do
      should contain_firewall('resolver_udp_53').with_enable(true)
    end
  end

  describe 'Test with default domain' do
    let(:params) { { :dns_servers => ['nameserver1', 'nameserver2'] } }

    it { should contain_file('resolv.conf').with_ensure('file') }
    it 'should generate a valid template' do
      should contain_file('resolv.conf').with ({
        'content' => /domain test.com/,
        'content' => /nameserver nameserver1/,
        'content' => /nameserver nameserver2/
      })
    end
    it 'should not request a source' do
      should contain_file('resolv.conf').with_source(nil)
    end
  end

  describe 'Test parameters as arrays' do
    let(:params) { {:dns_domain => 'the_domain', :search => ['search1', 'search2'], :dns_servers => ['nameserver1', 'nameserver2'], :sortlist => ['sort1', 'sort2'] } }

    it 'should generate a valid template' do
      should contain_file('resolv.conf').with ({
        'content' => /domain the_domain/,
        'content' => /search search1 search2/,
        'content' => /nameserver nameserver1/,
        'content' => /nameserver nameserver2/,
        'content' => /sortlist sort1 sort2/
      })
      should contain_file('resolv.conf').without_content(/options/)
    end
    it 'should not request a source' do
      should contain_file('resolv.conf').with_source(nil)
    end
  end

  describe 'Test parameters as strings' do
    let(:params) { {:dns_domain => 'the_domain', :search => 'search1,search2', :dns_servers => 'nameserver1,nameserver2', :sortlist => 'sort1,sort2' } }

    it 'should generate a valid template' do
      should contain_file('resolv.conf').with ({
        'content' => /domain the_domain/,
        'content' => /nameserver nameserver1/,
        'content' => /nameserver nameserver2/,
        'content' => /search search1 search2/,
        'content' => /sortlist sort1 sort2/
      })
      should contain_file('resolv.conf').without_content(/options/)
    end
    it 'should not request a source' do
      should contain_file('resolv.conf').with_source(nil)
    end
  end

  describe 'Test options' do
    let(:params) { {:dns_domain => 'the_domain', :dns_servers => 'server1', :options => { 'opt_a' => 'value_a', 'opt_b' => 'value_b', 'opt_c' => '' } } }

    it 'should generate a valid template' do
      should contain_file('resolv.conf').with ({
        'content' => /domain the_domain/,
        'content' => /nameserver server1/,
        'content' => /options opt_a:value_a/,
        'content' => /options opt_b:value_b/,
        'content' => /options opt_c/
      })
      should contain_file('resolv.conf').without ({
          'content' => /search/,
          'content' => /sortlist/
      })
    end
    it 'should not request a source' do
      should contain_file('resolv.conf').with_source(nil)
    end
  end

  describe 'Test customizations - template' do
    let(:params) { {:template => "resolver/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it 'should generate a valid template' do
      should contain_file('resolv.conf').with_content(/fqdn: rspec.example42.com/)
    end
    it 'should generate a template that uses custom options' do
      should contain_file('resolv.conf').with_content(/value_a/)
    end
    it 'should not request a source' do
      should contain_file('resolv.conf').with_source(nil)
    end
  end

  describe 'Test customizations - source' do
    let(:params) { { :source => "puppet://modules/resolver/spec" } }

    it 'should request a valid source' do
      should contain_file('resolv.conf').with_source("puppet://modules/resolver/spec")
    end
    it 'should not build template' do
      should contain_file('resolv.conf').with_content(nil)
    end
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "resolver::spec" } }
    it 'should automatically include a custom class' do
      should contain_file('resolv.conf').with_content(/fqdn: rspec.example42.com/)
    end
  end

  describe 'Test Puppi Integration' do
    let(:params) { {:puppi => true, :puppi_helper => "myhelper"} }

    it 'should generate a puppi::ze define' do
      should contain_puppi__ze('resolver').with_helper("myhelper")
    end
  end

end
