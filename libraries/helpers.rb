def database_yaml(rails_adapter = 'mysql2')
  common = {
    'host' => 'localhost',
    'username' => node['u2i-jenkins']['mysql']['username'],
    'password' => node['u2i-jenkins']['mysql']['password'],
    'adapter' => rails_adapter,
    'timeout' => 5000,
    'encoding' => 'utf8',
    'reconnect' => true,
    'pool' => 5
  }
  {
    'development' => {
      'database' => "<%= ENV['PROJECT_NAME'] %><%= ENV['JOB_SUFFIX'] %>"
    }.merge(common),
    'test' => {
      'database' => "<%= ENV['PROJECT_NAME'] %>_test<%= ENV['JOB_SUFFIX'] %>"
    }.merge(common)
  }.to_yaml
end
