#
# Cookbook Name:: jenkins-chef-dsl
# Recipe:: auth
#
# Configures Authentication.

home = node['jenkins']['master']['home']
keys = Chef::EncryptedDataBagItem.load('keys', 'jenkins')
user = 'chef'

directory File.join(home, '.ssh') do
  owner 'jenkins'
  group 'jenkins'
  mode '0744'
  action :create
end

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

permissions = []

permissions << 'hudson.model.Item.ViewStatus:anonymous'

permissions += (node['u2i-jenkins']['config']['users']['guests']).flat_map do |user|
  %W(hudson.model.Hudson.Read:#{user}
     hudson.model.Item.Read:#{user}
     hudson.model.Item.ViewStatus:#{user}
     hudson.model.View.Read:#{user})
end

developers = node['u2i-jenkins']['config']['users']['developers']
permissions += developers.flat_map do |user|
  %W(hudson.model.Hudson.Read:#{user}
     hudson.model.Item.Build:#{user}
     hudson.model.Item.Cancel:#{user}
     hudson.model.Item.Configure:#{user}
     hudson.model.Item.Create:#{user}
     hudson.model.Item.Delete:#{user}
     hudson.model.Item.Discover:#{user}
     hudson.model.Item.Read:#{user}
     hudson.model.Item.ViewStatus:#{user}
     hudson.model.Item.Workspace:#{user}
     hudson.model.Run.Delete:#{user}
     hudson.model.Run.Update:#{user}
     hudson.model.View.Read:#{user}
     hudson.scm.SCM.Tag:#{user})
end

permissions += (node['u2i-jenkins']['config']['users']['admins'] + [user]).flat_map do |admin|
  %W(com.cloudbees.plugins.credentials.CredentialsProvider.Create:#{admin}
     com.cloudbees.plugins.credentials.CredentialsProvider.Delete:#{admin}
     com.cloudbees.plugins.credentials.CredentialsProvider.ManageDomains:#{admin}
     com.cloudbees.plugins.credentials.CredentialsProvider.Update:#{admin}
     com.cloudbees.plugins.credentials.CredentialsProvider.View:#{admin}
     hudson.model.Computer.Build:#{admin}
     hudson.model.Computer.Configure:#{admin}
     hudson.model.Computer.Connect:#{admin}
     hudson.model.Computer.Create:#{admin}
     hudson.model.Computer.Delete:#{admin}
     hudson.model.Computer.Disconnect:#{admin}
     hudson.model.Hudson.Administer:#{admin}
     hudson.model.Hudson.ConfigureUpdateCenter:#{admin}
     hudson.model.Hudson.Read:#{admin}
     hudson.model.Hudson.RunScripts:#{admin}
     hudson.model.Hudson.UploadPlugins:#{admin}
     hudson.model.Item.Build:#{admin}
     hudson.model.Item.Cancel:#{admin}
     hudson.model.Item.Configure:#{admin}
     hudson.model.Item.Create:#{admin}
     hudson.model.Item.Delete:#{admin}
     hudson.model.Item.Discover:#{admin}
     hudson.model.Item.Read:#{admin}
     hudson.model.Item.ViewStatus:#{admin}
     hudson.model.Item.Workspace:#{admin}
     hudson.model.Run.Delete:#{admin}
     hudson.model.Run.Update:#{admin}
     hudson.model.View.Configure:#{admin}
     hudson.model.View.Create:#{admin}
     hudson.model.View.Delete:#{admin}
     hudson.model.View.Read:#{admin}
     hudson.scm.SCM.Tag:#{admin})
end

authenticated_permissions = %w(
  hudson.model.Hudson.Read:authenticated
  hudson.model.Item.Build:authenticated
  hudson.model.Item.Cancel:authenticated
  hudson.model.Item.Configure:authenticated
  hudson.model.Item.Create:authenticated
  hudson.model.Item.Delete:authenticated
  hudson.model.Item.Discover:authenticated
  hudson.model.Item.Read:authenticated
  hudson.model.Item.ViewStatus:authenticated
  hudson.model.Item.Workspace:authenticated
  hudson.model.Run.Delete:authenticated
  hudson.model.Run.Update:authenticated
  hudson.model.View.Read:authenticated
  hudson.scm.SCM.Tag:authenticated
)

permissions_groovy = permissions.uniq.map do |permission|
  "strategy.add(\"#{permission}\")"
end.join("\n")

authenticated_permissions_groovy = authenticated_permissions.uniq.map do |permission|
  "strategy.add(\"#{permission}\")"
end.join("\n")

jenkins_script 'setup authentication' do
  command <<-EOH.gsub(/^ {4}/, '')
    import  org.jenkinsci.plugins.googlelogin.*;
    import  org.jenkins.model.*;
    import  hudson.security.*;

    import  jenkins.*;
    import  jenkins.model.*;
    import  hudson.*;
    import  hudson.model.*;

    def clientId     = "#{node['u2i-jenkins']['config']['plugins']['google-login']['clientId']}";
    def clientSecret = "#{node['u2i-jenkins']['config']['plugins']['google-login']['clientSecret']}";
    def domain       = "#{node['u2i-jenkins']['config']['plugins']['google-login']['domain']}";
    def instance = Jenkins.getInstance();

    def info = new GoogleUserInfo();
    def realm = new GoogleOAuth2SecurityRealm(clientId, clientSecret, domain);

    def strategy = new GlobalMatrixAuthorizationStrategy();
    #{permissions_groovy}
    #{authenticated_permissions_groovy}

    instance.setSecurityRealm(realm);
    instance.setAuthorizationStrategy(strategy);
    instance.save();
  EOH

  notifies :create, 'ruby_block[security_enabled]', :immediately
end

ruby_block 'security_enabled' do
  block do
    node.run_state[:jenkins_private_key] = keys['users'][user]['private_key']
  end
  action :nothing
end
