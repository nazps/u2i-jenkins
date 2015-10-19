rubies = %w(2.1.5 2.2.3)

default['rvm']['user_installs'] = [
  {
    'user' => 'jenkins',
    'default_ruby' => '2.1.5',
    'rubies' => rubies,
    'home' => node['u2i-jenkins']['home'],
    'rvmrc' => {
      'rvm_install_on_use_flag' => 1,
      'rvm_project_rvmrc' => 1,
      'rvm_gemset_create_on_use_flag' => 1,
      'rvm_autolibs_flag' => 'disabled'
    }
  }
]
