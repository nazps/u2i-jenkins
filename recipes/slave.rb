include_recipe 'u2i-jenkins::_common'
include_recipe 'u2i-jenkins::_services'

# Create the Jenkins user
user node['jenkins']['master']['user'] do
  home node['jenkins']['master']['home']
  system node['jenkins']['master']['use_system_accounts']
end

# Create the Jenkins group
group node['jenkins']['master']['group'] do
  members node['jenkins']['master']['user']
  system node['jenkins']['master']['use_system_accounts']
end

# Create the home directory
directory node['jenkins']['master']['home'] do
  owner     node['jenkins']['master']['user']
  group     node['jenkins']['master']['group']
  mode      '0755'
  recursive true
end

include_recipe 'u2i-jenkins::_rvm'

ruby_block 'jenkins_service_restart_flag' do
  block do
    # mock service
  end
  action :nothing
end
