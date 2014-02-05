# = Class: resolver
#
# This is the main resolver class
#
#
# == Parameters
#
# Class specific paramers
#
# [*dns_domain*]
#   DNS domain to configure.
#
# [*dns_servers*]
#   IP of the nameservers to use. Can be an array.
#
# [*search*]
#   Name of the search domains to use. Can be an array.
#
# [*sortlist*]
#   IP-address-netmask pairs to use for the sortlist option. Can be an array.
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, resolver class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $resolver_myclass
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, resolver main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $resolver_source
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, resolver main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $resolver_template
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $resolver_options
#
# [*monitor*]
#   Set to 'true' to enable monitoring of the services provided by the module
#   Can be defined also by the (top scope) variables $resolver_monitor
#   and $monitor
#
# [*monitor_tool*]
#   Define which monitor tools (ad defined in Example42 monitor module)
#   you want to use for resolver checks
#   Can be defined also by the (top scope) variables $resolver_monitor_tool
#   and $monitor_tool
#
# [*monitor_target*]
#   The Ip address or hostname to use as a target for monitoring tools.
#   Default is the fact $ipaddress
#   Can be defined also by the (top scope) variables $resolver_monitor_target
#   and $monitor_target
#
# [*puppi*]
#   Set to 'true' to enable creation of module data files that are used by puppi
#   Can be defined also by the (top scope) variables $resolver_puppi and $puppi
#
# [*puppi_helper*]
#   Specify the helper to use for puppi commands. The default for this module
#   is specified in params.pp and is generally a good choice.
#   You can customize the output of puppi commands for this module using another
#   puppi helper. Use the define puppi::helper to create a new custom helper
#   Can be defined also by the (top scope) variables $resolver_puppi_helper
#   and $puppi_helper
#
# [*firewall*]
#   Set to 'true' to enable firewalling of the services provided by the module
#   Can be defined also by the (top scope) variables $resolver_firewall
#   and $firewall
#
# [*firewall_tool*]
#   Define which firewall tool(s) (ad defined in Example42 firewall module)
#   you want to use to open firewall for resolver port(s)
#   Can be defined also by the (top scope) variables $resolver_firewall_tool
#   and $firewall_tool
#
# [*firewall_src*]
#   Define which source ip/net allow for firewalling resolver.
#   Default: 0.0.0.0/0. Can be defined also by the (top scope) variables
#   $resolver_firewall_src and $firewall_src
#
# [*firewall_dst*]
#   Define which destination ip to use for firewalling. Default: $ipaddress
#   Can be defined also by the (top scope) variables $resolver_firewall_dst
#   and $firewall_dst
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#   Can be defined also by the (top scope) variables $resolver_debug and $debug
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $resolver_audit_only
#   and $audit_only
#
# Default class params - As defined in resolver::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*config_file*]
#   Main configuration file path
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# == Author
#   Alessandro Franceschi <al@lab42.it/>
#
class resolver (
  $dns_domain          = params_lookup( 'dns_domain' , 'global' ),
  $dns_servers         = params_lookup( 'dns_servers' , 'global' ),
  $search              = params_lookup( 'search' ),
  $sortlist            = params_lookup( 'sortlist' ),
  $my_class            = params_lookup( 'my_class' ),
  $source              = params_lookup( 'source' ),
  $template            = params_lookup( 'template' ),
  $options             = params_lookup( 'options' ),
  $absent              = params_lookup( 'absent' ),
  $monitor             = params_lookup( 'monitor' , 'global' ),
  $monitor_tool        = params_lookup( 'monitor_tool' , 'global' ),
  $monitor_target      = params_lookup( 'monitor_target' , 'global' ),
  $puppi               = params_lookup( 'puppi' , 'global' ),
  $puppi_helper        = params_lookup( 'puppi_helper' , 'global' ),
  $firewall            = params_lookup( 'firewall' , 'global' ),
  $firewall_tool       = params_lookup( 'firewall_tool' , 'global' ),
  $firewall_src        = params_lookup( 'firewall_src' , 'global' ),
  $firewall_dst        = params_lookup( 'firewall_dst' , 'global' ),
  $debug               = params_lookup( 'debug' , 'global' ),
  $audit_only          = params_lookup( 'audit_only' , 'global' ),
  $config_file         = params_lookup( 'config_file' ),
  $config_file_mode    = params_lookup( 'config_file_mode' ),
  $config_file_owner   = params_lookup( 'config_file_owner' ),
  $config_file_group   = params_lookup( 'config_file_group' )
  ) inherits resolver::params {

  $bool_absent=any2bool($absent)
  $bool_monitor=any2bool($monitor)
  $bool_puppi=any2bool($puppi)
  $bool_firewall=any2bool($firewall)
  $bool_debug=any2bool($debug)
  $bool_audit_only=any2bool($audit_only)
  $array_dns_servers = is_array($resolver::dns_servers) ? {
    false     => $resolver::dns_servers ? {
      ''      => [],
      default => split($resolver::dns_servers, ','),
    },
    default   => $resolver::dns_servers,
  }
  $array_search = is_array($resolver::search) ? {
    false     => $resolver::search ? {
      ''      => [],
      default => split($resolver::search, ','),
    },
    default   => $resolver::search,
  }
  $array_sortlist = is_array($resolver::sortlist) ? {
    false     => $resolver::sortlist ? {
      ''      => [],
      default => split($resolver::sortlist, ','),
    },
    default   => $resolver::sortlist,
  }

  ### Definition of some variables used in the module
  $manage_file = $resolver::bool_absent ? {
    true    => 'absent',
    default => 'file',
  }

  $manage_audit = $resolver::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $resolver::bool_audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $resolver::source ? {
    ''        => undef,
    default   => $resolver::source,
  }

  $manage_file_content = $resolver::template ? {
    ''          => $resolver::dns_servers ? {
      ''        => undef,
      default   => $resolver::dns_domain ? {
        ''      => undef,
        default => template('resolver/resolv.conf.erb'),
      },
    },
    default     => template($resolver::template),
  }

  ### Managed resources
  file { 'resolv.conf':
    ensure  => $resolver::manage_file,
    path    => $resolver::config_file,
    mode    => $resolver::config_file_mode,
    owner   => $resolver::config_file_owner,
    group   => $resolver::config_file_group,
    source  => $resolver::manage_file_source,
    content => $resolver::manage_file_content,
    replace => $resolver::manage_file_replace,
    audit   => $resolver::manage_audit,
  }

  ### Include custom class if $my_class is set
  if $resolver::my_class {
    include $resolver::my_class
  }


  ### Provide puppi data, if enabled ( puppi => true )
  if $resolver::bool_puppi == true {
    $classvars=get_class_args()
    puppi::ze { 'resolver':
      ensure    => $resolver::manage_file,
      variables => $classvars,
      helper    => $resolver::puppi_helper,
    }
  }


  ### Service monitoring
  if $resolver::bool_monitor {
#    monitor::plugin { "resolver_plugin":
#      protocol => $resolver::protocol,
#      port     => $resolver::port,
#      target   => $resolver::monitor_target,
#      tool     => $resolver::monitor_tool,
#      enable   => $resolver::bool_monitor,
#    }
  }


  ### Firewall management, if enabled ( firewall => true )
  if $resolver::bool_firewall == true {
    firewall { 'resolver_udp_53':
      source      => $resolver::firewall_src,
      destination => $resolver::dns_servers,
      protocol    => 'udp',
      port        => '53',
      action      => 'allow',
      direction   => 'output',
      tool        => $resolver::firewall_tool,
      enable      => $resolver::bool_firewall,
    }
    firewall { 'resolver_tcp_53':
      source      => $resolver::firewall_src,
      destination => $resolver::dns_servers,
      protocol    => 'tcp',
      port        => '53',
      action      => 'allow',
      direction   => 'output',
      tool        => $resolver::firewall_tool,
      enable      => $resolver::bool_firewall,
    }
  }


  ### Debugging, if enabled ( debug => true )
  if $resolver::bool_debug == true {
    file { 'debug_resolver':
      ensure  => $resolver::manage_file,
      path    => "${settings::vardir}/debug-resolver",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
    }
  }

}
