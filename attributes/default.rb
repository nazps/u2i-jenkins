override['jenkins']['master']['port'] = 8080

default['u2i-jenkins']['projects_dir'] = '/var/proj'
default['mysql']['server_root_password'] = 'jenkins'

default['u2i-jenkins']['jobs'] = {}

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
        {
          'groupRegex' => "\\((?!pr)\\w+\\)\\ #{jobname}",
          'namingRule' => jobname
        }
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

default['u2i-jenkins']['config']['plugins']['coverage']['default'] = {
  'total' => {
    'healthy' => 80,
    'unhealthy' => 0,
    'unstable' => 0
  },
  'code' => {
    'healthy' => 80,
    'unhealthy' => 70,
    'unstable' => 50
  }
}

default['u2i-jenkins']['config']['plugins']['rubocop']['default'] = {
  'min' => 10,
  'max' => 20,
  'unstable' => 30
}

default['u2i-jenkins']['config']['plugins']['checkstyle']['default'] = {
  'min' => 10,
  'max' => 20,
  'unstable' => 30
}

default['u2i-jenkins']['config']['plugins']['pmd']['default'] = {
  'min' => 10,
  'max' => 20,
  'unstable' => 30
}

default['u2i-jenkins']['config']['plugins']['findbugs']['default'] = {
  'min' => 10,
  'max' => 20,
  'unstable' => 30
}

default['u2i-jenkins']['config']['keep_builds']['default'] = {
  'days' => 60,
  'num' => 50
}

default['u2i-jenkins']['config']['plugins']['google-login']['clientId'] = ''
default['u2i-jenkins']['config']['plugins']['google-login']['clientSecret'] = ''
default['u2i-jenkins']['config']['plugins']['google-login']['domain'] = 'u2i.com'

force_override['apache']['listen_ports'] = ['80']
