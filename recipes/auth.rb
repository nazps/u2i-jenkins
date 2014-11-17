#
# Cookbook Name:: jenkins-chef-dsl
# Recipe:: auth
#
# Configures Authentication.

home = node['jenkins']['master']['home']
keys = Chef::EncryptedDataBagItem.load('keys', 'jenkins')
user = 'chef'

file File.join(home, '.ssh', "#{user}.id_rsa") do
  content keys['users'][user]['private_key']
  user 'jenkins'
  group 'jenkins'
  mode 0600
end

file File.join(home, '.ssh', "#{user}.id_rsa.pub") do
  content keys['users'][user]['public_key']
  user 'jenkins'
  group 'jenkins'
  mode 0644
end

include_recipe 'u2i-jenkins::_is_secured'

# Creates the 'chef' Jenkins user and assciates the public key
#!!  Needs anonymous auth to create a user, to then use this users there after.
jenkins_user user do
  full_name 'Chef Client'
  public_keys [keys['users'][user]['public_key']]
  password keys['users'][user]['password'] if keys['users'][user]['password']
end

jenkins_script 'setup authentication' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    def instance = Jenkins.getInstance()
    import hudson.security.*
    def realm = new HudsonPrivateSecurityRealm(false)
    instance.setSecurityRealm(realm)
    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    instance.setAuthorizationStrategy(strategy)
    instance.save()
  EOH

  notifies :create, 'ruby_block[security_enabled]', :immediately
end

ruby_block 'security_enabled' do
  block do
    node.run_state[:jenkins_private_key] = keys['users'][user]['private_key']
  end
  action :nothing
end
