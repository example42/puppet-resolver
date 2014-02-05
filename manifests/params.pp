# Class: resolver::params
#
# This class defines default parameters used by the main module class resolver
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to resolver class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class resolver::params {

  ### Module's specific parameters
  $dns_domain = $::domain
  $dns_servers = ''
  $search = ''
  $sortlist = ''

  ### Application related parameters

  $config_file = $::operatingsystem ? {
    default => '/etc/resolv.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    /(?i:FreeBSD|OpenBSD)/ => 'wheel',
    default                => 'root',
  }

  # General Settings
  $my_class = ''
  $source = ''
  $template = ''
  $options = ''

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = ''
  $puppi = false
  $puppi_helper = 'resolver'
  $debug = false
  $audit_only = false

}
