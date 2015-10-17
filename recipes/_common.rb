include_recipe 'apt'

if node['jenkins']['master']['install_method'] == 'war'
  include_recipe 'java::default'
end

include_recipe 'maven'
ssh_known_hosts_entry 'github.com'

chef_gem 'activesupport'
