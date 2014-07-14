node['u2i-jenkins']['jobs'].each do |_jobname, config|
  include_recipe config['recipe']
end
