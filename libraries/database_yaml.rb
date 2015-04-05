def database_yaml(jobname, branch)
  common = {
    'host' => 'localhost',
    'username' => node['u2i-jenkins']['mysql']['username'],
    'password' => node['u2i-jenkins']['mysql']['password'],
    'adapter' => 'mysql',
    'timeout' => 5000,
    'encoding' => 'utf8',
    'reconnect' => true,
    'pool' => 5
  }
  {
    'development' => {
      'database' => "#{jobname}_#{branch}"
    }.merge(common),
    'test' => {
      'database' => "#{jobname}_#{branch}_test"
    }.merge(common)
  }.to_yaml
end
