def instance_type_executors(node)
  return node['u2i-jenkins']['slave']['executors'] unless node['u2i-jenkins']['slave']['executors'].nil?
  return 2 if node['ec2'].nil?
  case node['ec2']['instance_type']
  when 'c3.2xlarge'
    8
  when 'c3.xlarge'
    4
  when 'c3.large'
    2
  else
    2
  end
end
