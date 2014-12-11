rubies = %w(1.9.3-p547 2.1.5)
gems = {
  '2.1.5@global' => [
    {'name' => 'rubocop'},
    {'name' => 'rubocop-rspec'},
    {'name' => 'rubocop-checkstyle_formatter'}
  ]
}

default['rvm']['user_installs'] = [
  {
    'user' => 'jenkins',
    'default_ruby' => '2.1.5',
    'rubies' => rubies,
    'gems' => gems,
    'home' => node['jenkins']['master']['home'],
    'rvmrc' => {
      'rvm_install_on_use_flag' => 1,
      'rvm_project_rvmrc' => 1,
      'rvm_gemset_create_on_use_flag' => 1,
      'rvm_autolibs_flag' => 'disabled'
    }
  }
]
