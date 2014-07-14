default['rvm']['group_users'] = %w(jenkins)
default['jenkins']['master']['groups'] = %w(jenkins rvm)

rubies = %w(1.9.3 2.1.1)
gems = {
  '2.1.1@global' => [{'name' => 'rubocop'},
                     {'name' => 'rubocop-rspec'},
                     {'name' => 'rubocop-checkstyle_formatter'}
  ]
}
jobs = default['u2i-jenkins']['jobs'].map { |jobname, _config| jobname }

default['rvm']['default_ruby'] = '2.1.1'
default['rvm']['rubies'] = rubies

default['rvm']['gems'] = gems
