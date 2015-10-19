include_recipe 'u2i-jenkins::_common'
include_recipe 'u2i-jenkins::_services'

# Create the Jenkins user
user node['u2i-jenkins']['slave']['user'] do
  home node['u2i-jenkins']['slave']['home']
  system false
end

# Create the Jenkins group
group node['u2i-jenkins']['slave']['group'] do
  members node['u2i-jenkins']['slave']['user']
  system false
end

# Create the home directory
directory node['u2i-jenkins']['slave']['home'] do
  owner     node['u2i-jenkins']['slave']['user']
  group     node['u2i-jenkins']['slave']['group']
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
