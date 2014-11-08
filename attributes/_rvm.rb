rubies = %w(1.9.3-p547 2.1.3)
gems = {
  '2.1.3@global' => [{'name' => 'rubocop'},
                     {'name' => 'rubocop-rspec'},
                     {'name' => 'rubocop-checkstyle_formatter'}]
}

default['rvm']['default_ruby'] = '2.1.3'
default['rvm']['rubies'] = rubies

default['rvm']['gems'] = gems

default['rvm']['rvmrc'] = {
  'rvm_install_on_use_flag' => 1,
  'rvm_project_rvmrc' => 1,
  'rvm_gemset_create_on_use_flag' => 1,
}
