restart_required = false

ruby_block 'jenkins_service_restart_flag' do
  block do
    # restart_required = true
  end
  action :nothing
end

service 'jenkins' do
  action :restart
  only_if { restart_required }
end
