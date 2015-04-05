override['jenkins']['master']['port'] = 8080

default['u2i-jenkins']['projects_dir'] = '/var/proj'

branches = %w(master pr)

default['u2i-jenkins']['jobs'] = {
  'u2i-jenkins-rails_project' => {
    'type' => 'ruby',
    'ruby_version' => '2.1.3',
    'recipe' => 'u2i-jenkins::_jobs_project',
    'branches' => branches,
    'rubocop' => {
      'enabled' => true,
      'min' => 10,
      'max' => 20,
      'unstable' => 30
    },
    'credential_name' => 'u2i-jenkins-rails_project',
    'repository' => {
      'organisation' => 'mknapik',
      'name' => 'u2i-jenkins-rails_project'
    }
  },
  'u2i-jenkins-matrix_project' => {
    'type' => 'ruby-matrix',
    'ruby_version' => '2.1.3',
    'recipe' => 'u2i-jenkins::_jobs_matrix',
    'branches' => branches,
    'rubocop' => {
      'enabled' => true,
      'min' => 10,
      'max' => 20,
      'unstable' => 30
    },
    'credential_name' => 'u2i-jenkins-matrix_project',
    'repository' => {
      'organisation' => 'mknapik',
      'name' => 'u2i-jenkins-matrix_project'
    },
    'matrix' => {
      'combination_filter' => '!(RUBY_VERSION==&quot;1.8.7&quot; &amp;&amp; RAILS_VERSION==&quot;4&quot;)',
      'axes' => {
        'RUBY_VERSION' => %w(1.9.3-p547 2.1.3),
        'RAILS_VERSION' => %w(2 3 4)
      }
    }
  }
}

default['u2i-jenkins']['config']['views'] = {
  'listView' => {
    'master' => {
      'includeRegex' => '\(master\)\ .+'
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

