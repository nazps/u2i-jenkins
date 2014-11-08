def database_yaml(jobname, branch)
  common = {
    'host' => 'localhost',
    'username' => 'root',
    'password' => node['mysql']['server_root_password'],
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
