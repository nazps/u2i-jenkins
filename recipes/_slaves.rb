keys = Chef::EncryptedDataBagItem.load('keys', 'jenkins')

credential_name = 'jenkins-slave'

jenkins_private_key_credentials credential_name do
  id keys['credentials'][credential_name]['id'].dup
  username 'jenkins'
  private_key keys['credentials'][credential_name]['private_key'].dup
  description keys['credentials'][credential_name]['description'].dup
end

search(:node, 'recipes:u2i-jenkins\:\:slave').each do |n|
  jenkins_ssh_slave n.name do
    description 'executor'
    remote_fs n['u2i-jenkins']['slave']['home']
    labels n['u2i-jenkins']['slave']['labels']

    executors instance_type_executors

    host n['ec2']['local_ipv4']
    credentials keys['credentials'][credential_name]['id'].dup
    action :create
  end
end
