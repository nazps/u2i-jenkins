home = node['jenkins']['master']['home']

include_recipe 'u2i-jenkins::_common'
include_recipe 'jenkins::master'
include_recipe 'u2i-jenkins::_plugins'

group 'rvm' do
  notifies :create, 'ruby_block[jenkins_service_restart_flag]', :delayed
  members %w(jenkins)
  append  true
end

## Configs

configs = %w(
  .gitconfig
  hudson.plugins.git.GitSCM.xml
  hudson.plugins.git.GitTool.xml
  hudson.tasks.Mailer.xml
  hudson.tasks.Shell.xml
  jenkins.model.JenkinsLocationConfiguration.xml
  hudson.plugins.emailext.ExtendedEmailPublisher.xml
  hudson.tasks.Maven.xml
)
template File.join(home, 'config.xml') do
  source 'jenkins/config.xml.erb'
  owner 'jenkins'
  group 'jenkins'
  action :create_if_missing
end

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

include_recipe 'u2i-jenkins::_proxy'
