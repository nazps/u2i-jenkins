default['u2i-jenkins']['slave']['home'] = '/mnt/jenkins'
default['u2i-jenkins']['slave']['user'] = 'jenkins'
default['u2i-jenkins']['slave']['group'] = 'jenkins'
default['u2i-jenkins']['slave']['labels'] = %w(executor)
default['u2i-jenkins']['slave']['executors'] = nil
default['u2i-jenkins']['home'] = node['u2i-jenkins']['slave']['home']
