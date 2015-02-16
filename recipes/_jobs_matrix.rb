job_name = 'u2i-jenkins-matrix_project'

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
              key_id: credentials[node['u2i-jenkins']['jobs'][job_name]['credential_name']]['id'],
              repository: node['u2i-jenkins']['jobs'][job_name]['repository'],
              branch: branch,
              ruby_version: node['u2i-jenkins']['jobs'][job_name]['ruby_version'],
              ruby_gemset: job_name,
              matrix_axes: node['u2i-jenkins']['jobs'][job_name]['matrix']['axes'],
              combination_filter: node['u2i-jenkins']['jobs'][job_name]['matrix']['combination_filter']
  end

  # jenkins_job "\(#{branch}\)\ #{job_name}" do
  #   config config
  # end
end
