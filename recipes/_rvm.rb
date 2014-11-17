include_recipe 'apt'
include_recipe 'rvm::system'

group 'rvm' do
  notifies :create, 'ruby_block[jenkins_service_restart_flag]', :delayed
  members %w(vagrant)
  append  true
end
