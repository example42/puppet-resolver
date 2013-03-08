# Puppet module: resolver

This is a Puppet module for resolver based on the second generation layout ("NextGen") of Example42 Puppet Modules.

Made by Alessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-resolver

Released under the terms of Apache 2 License.

This module requires functions provided by the Example42 Puppi module (you need it even if you don't use and install Puppi)

For detailed info about the logic and usage patterns of Example42 modules check the DOCS directory on Example42 main modules set.

## USAGE - Basic management

* Configure /etc/resolv.conf with custom dns servers and search paths

        class { 'resolver': 
          dns_servers => [ '8.8.8.8' , '8.8.4.4' ],
          search      => [ 'example42.com' , 'example42.lan' ],
        }

* Configure /etc/resolv.conf with specific dns server and custom options (provide them as an hash)

        class { 'resolver':
          dns_servers => [ '8.8.8.8' , '8.8.4.4' ],
          search      => [ 'example42.com' , 'example42.lan' ],
          options     => {
            'rotate'  => '',
            'timeout' => '2',
          },
        }

* Enable auditing without without making changes on existing resolver configuration files

        class { 'resolver':
          audit_only => true
        }


## USAGE - Overrides and Customizations
* Use static custom sources to populate resolv.conf

        class { 'resolver':
          source => [ "puppet:///modules/lab42/resolver/resolv.conf-${hostname}" , "puppet:///modules/lab42/resolver/resolv.conf" ], 
        }


* Use custom template for main config file. Note that template and source arguments are alternative. 

        class { 'resolver':
          template => 'example42/resolver/resolver.conf.erb',
        }

* Automatically include a custom subclass

        class { 'resolver':
          my_class => 'resolver::example42',
        }


## USAGE - Example42 extensions management 
* Activate puppi (recommended, but disabled by default)

        class { 'resolver':
          dns_servers => '8.8.8.8',
          puppi       => true,
        }

* Activate puppi and use a custom puppi_helper template (to be provided separately with a puppi::helper define ) to customize the output of puppi commands 

        class { 'resolver':
          dns_servers  => '8.8.8.8',
          puppi        => true,
          puppi_helper => 'myhelper', 
        }

* Activate automatic monitoring (recommended, but disabled by default). This option requires the usage of Example42 monitor and relevant monitor tools modules

        class { 'resolver':
          dns_servers  => [ '8.8.8.8' , '8.8.4.4' ],
          monitor      => true,
          monitor_tool => [ 'nagios' , 'puppi' ],
        }

* Activate automatic firewalling. This option requires the usage of Example42 firewall and relevant firewall tools modules. Note that firewall rules are automatically applied outbound for port udp/54 to the specified dns_servers.

        class { 'resolver':     
          dns_servers   => [ '8.8.8.8' , '8.8.4.4' ],
          firewall      => true,
          firewall_tool => 'iptables',
        }


[![Build Status](https://travis-ci.org/example42/puppet-resolver.png?branch=master)](https://travis-ci.org/example42/puppet-resolver)
