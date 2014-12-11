include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

http_dir = '/etc/apache2'

template File.join(http_dir, 'sites-available', 'jenkins.proxy.conf') do
  source 'etc/apache2/sites-available/jenkins.proxy.conf.erb'
end

service 'apache2' do
  action :reload
end

apache_site 'jenkins.proxy' do
  enable true
end
