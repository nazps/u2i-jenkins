job_name = 'u2i-jenkins-rails_project'

dev_path = node['u2i-jenkins']['jobs'][job_name]['project_dir']
dev_path ||= File.join(node['u2i-jenkins']['projects_dir'], job_name)

keys = Chef::EncryptedDataBagItem.load('keys', 'jenkins')
credentials = keys['credentials']

branches = node['u2i-jenkins']['jobs'][job_name]['branches']
rubocop_metrics = node['u2i-jenkins']['jobs'][job_name]['rubocop']
config_template = "jenkins/jobs/#{job_name}.config.xml.erb"

branches.each do |branch|
  file_branch_name = branch.gsub('/', ':')
  config = File.join(Chef::Config[:file_cache_path], "#{job_name}_#{file_branch_name}.config.xml")

  template config do
    source config_template
    variables simplecov_report: true,
              rubocop_metrics: rubocop_metrics,
              rcov_report: true,
              rails_report: true,
              metric_fu_report: true,
              brakeman_report: true,
              key_id: credentials[node['u2i-jenkins']['jobs'][job_name]['credential_name']]['id'],
              repository: node['u2i-jenkins']['jobs'][job_name]['repository'],
              branch: branch,
              ruby_version: node['u2i-jenkins']['jobs'][job_name]['ruby_version'],
              ruby_gemset: job_name
  end

  jenkins_job "\(#{branch}\)\ #{job_name}" do
    config config
  end

  directory File.join(dev_path, 'config', branch) do
    owner 'jenkins'
    group 'jenkins'
    action :create
    recursive true
  end

  file File.join(dev_path, 'config', branch, 'database.yml') do
    content(node['u2i-jenkins']['jobs'][job_name]['db'] ||
              database_yaml(job_name, branch))
    owner 'jenkins'
    group 'jenkins'
    mode 0644
    action :create
  end
end
