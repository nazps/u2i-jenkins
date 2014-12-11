default['u2i-jenkins']['config']['address'] = node['u2i-jenkins']['config']['domain']
default['u2i-jenkins']['config']['aliases'] = [
  "www.#{node['u2i-jenkins']['config']['address']}"
]

if node['ec2']
  default['u2i-jenkins']['config']['aliases'] += [
    node['ec2']['local_ipv4'],
    node['ec2']['local_hostname'],
    node['ec2']['public_hostname'],
    node['ec2']['public_ipv4'],
  ]
end

force_override['apache']['listen_ports'] = ['80']
