home = node['jenkins']['master']['home']

include_recipe 'apt'

if node['jenkins']['master']['install_method'] == 'war'
  include_recipe 'java::default'
end

include_recipe 'jenkins::master'
include_recipe 'u2i-jenkins::_plugins'

group 'rvm' do
  notifies :create, 'ruby_block[jenkins_service_restart_flag]', :immediately
  members %w(jenkins)
  append  true
end

ssh_known_hosts_entry 'github.com'

## Configs

configs = %w(
  .gitconfig
  config.xml
  hudson.plugins.git.GitSCM.xml
  hudson.plugins.git.GitTool.xml
  hudson.tasks.Mailer.xml
  jenkins.model.JenkinsLocationConfiguration.xml
  hudson.plugins.emailext.ExtendedEmailPublisher.xml
)

configs.each do |config|
  template File.join(home, config) do
    source "jenkins/#{config}.erb"
    owner 'jenkins'
    group 'jenkins'
  end
end

keys = Chef::EncryptedDataBagItem.load('keys', 'jenkins')
github_config = File.join(home, 'com.cloudbees.jenkins.GitHubPushTrigger.xml')
ghprb_config = File.join(home, 'org.jenkinsci.plugins.ghprb.GhprbTrigger.xml')

template ghprb_config do
  source 'jenkins/org.jenkinsci.plugins.ghprb.GhprbTrigger.xml.erb'
  owner 'jenkins'
  group 'jenkins'
  variables access_token: keys['GhprbTrigger']['accessToken'],
            admins: keys['GhprbTrigger']['admins'].join(', ')
end

template github_config do
  source 'jenkins/com.cloudbees.jenkins.GitHubPushTrigger.xml.erb'
  owner 'jenkins'
  group 'jenkins'
  variables access_token: keys['GitHubPushTrigger']['accessToken'],
            admins: keys['GitHubPushTrigger']['admins'].join(', ')
end
