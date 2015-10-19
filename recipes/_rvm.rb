include_recipe 'apt'

bash 'rvm gpg' do
  code <<-EOH
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  EOH
  user 'jenkins'
  group 'jenkins'
end

include_recipe 'rvm::user'
