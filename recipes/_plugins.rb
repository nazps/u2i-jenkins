restart_required = false

node['u2i-jenkins']['plugins']['install'].each do |plugin|
  jenkins_plugin plugin do
    notifies :create, 'ruby_block[jenkins_restart_flag]', :immediately
  end
end

node['u2i-jenkins']['plugins']['disable'].each do |plugin|
  jenkins_plugin plugin do
    action :disable
  end
end

# Is notified only when a 'jenkins_plugin' is installed or updated.
ruby_block 'jenkins_restart_flag' do
  block do
    restart_required = true
  end
  action :nothing
end

jenkins_command 'restart' do
  only_if { restart_required }
end
