home = node['jenkins']['master']['home']
keys = Chef::EncryptedDataBagItem.load('keys', 'jenkins')
user = 'chef'

# # Set the private key on the Jenkins executor, must be done only after the user
# #  has been created, otherwise API will require authentication and not be able
# #  to create the user.
node.run_state[:jenkins_private_key] = nil
node.set['jenkins']['executor']['private_key'] = nil

ruby_block 'set jenkins_private_key' do
  block do
    config_path = File.join(home, 'config.xml')

    if File.exists?(config_path)
      config = File.read(config_path)

      unsecured_regex = /<authorizationStrategy\s+class=".+Unsecured"\s*\/>/

      if config.match(unsecured_regex)
        puts '$$$ Jenkins is unsecured'
        node.run_state[:jenkins_private_key] = nil
      else
        puts '$$$ Jenkins is secured'
        node.run_state[:jenkins_private_key] = keys['users'][user]['private_key']
      end
    end
  end
end
