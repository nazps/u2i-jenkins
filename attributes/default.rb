override['jenkins']['master']['port'] = 8080

default['u2i-jenkins']['projects_dir'] = '/var/proj'
default['mysql']['server_root_password'] = 'jenkins'

branches = %w(master pr)

default['u2i-jenkins']['jobs'] = {
  'project1' => {
    'type' => 'ruby',
    'ruby_version' => '2.1.1',
    'recipe' => 'u2i-jenkins::_jobs_project1',
    'branches' => branches,
    'rubocop' => {
      'enabled' => true,
      'min' => 10,
      'max' => 20,
      'unstable' => 30
    },
    'credential_name' => 'jenkins',
    'repository' => {
      'organisation' => 'u2i',
      'name' => 'nttr'
    }
  },
  'matrix1' => {
    'type' => 'ruby-matrix',
    'ruby_version' => '2.1.1',
    'recipe' => 'u2i-jenkins::_jobs_matrix1',
    'branches' => branches,
    'rubocop' => {
      'enabled' => true,
      'min' => 10,
      'max' => 20,
      'unstable' => 30
    },
    'credential_name' => 'jenkins',
    'repository' => {
      'organisation' => 'u2i',
      'name' => 'sg_common'
    },
    'matrix' => {
      'combination_filter' => '!(RUBY_VERSION==&quot;1.8.7&quot; &amp;&amp; RAILS_VERSION==&quot;4&quot;)',
      'axes' => {
        'RUBY_VERSION' => %w(1.8.7 1.9.3 2.1.1),
        'RAILS_VERSION' => %w(2 3 4)
      }
    }
  }
}

default['u2i-jenkins']['config']['views'] = {
  'listView' => {
    'master' => {
      'includeRegex' => '\(master\)\ .+',
    },
    'pull requests' => {
      'includeRegex' => '\(pr\)\ .+'
    }
  },
  'CategorizedJobsView' => {
    'categorized' => {
      'includeRegex' => '\((?!pr)\w+\)\ .+',
      'categorizationCriteria' => node['u2i-jenkins']['jobs'].map do |jobname, _|
        {'groupRegex' => "\\((?!pr)\\w+\\)\\ #{jobname}",
         'namingRule' => jobname}
      end
    }

  },
  'BuildMonitorView' => {
    'monitor' => {
      'includeRegex' => '\(master\)\ .+'
    }
  }
}
default['u2i-jenkins']['config']['primaryView'] = 'categorized'

default['u2i-jenkins']['config']['address'] = node['u2i-jenkins']['config']['domain']
