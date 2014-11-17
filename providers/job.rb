require 'securerandom'

def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_jobs
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      delete_jobs
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end

def load_current_resource
  if @new_resource.type == :ruby_matrix
    if !defined?(@new_resource.matrix) || @new_resource.matrix.nil?
      fail 'Missing matrix attribute for ruby_matrix project'
    end
  end
  @current_resource = Chef::Resource::U2iJenkinsJob.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.rubocop(node['u2i-jenkins']['config']['plugins']['rubocop']['default'].deep_merge(@new_resource.rubocop))
  @current_resource.coverage(node['u2i-jenkins']['config']['plugins']['coverage']['default'].deep_merge(@new_resource.coverage))
end

private

def create_job(branch)
  if new_resource.key
    credentials = jenkins_private_key_credentials new_resource.name do
      description ''
      private_key new_resource.key
    end
    credentials_id = credentials.id
  elsif new_resource.key_id
    credentials_id = new_resource.key_id
  else
    credentials_id = nil
  end

  type_tag = case @new_resource.type
               when :ruby
                 'project'
               when :ruby_matrix
                 'matrix-project'
             end

  branch_file_name = branch.gsub('/', ':')
  config = ::File.join(Chef::Config[:file_cache_path], "#{new_resource.name}_#{branch_file_name}.config.xml")

  template config do
    source 'jenkins/job.config.xml.erb'
    variables job_name: new_resource.name,
              repository: new_resource.repository,
              branch: branch,
              builders: new_resource.builders,

              type: new_resource.type,
              matrix: new_resource.matrix,
              ws_cleanup: new_resource.ws_cleanup,
              keep_builds: new_resource.keep_builds,

              git_recursive: new_resource.git_recursive,

              ruby_version: new_resource.ruby_version,
              ruby_gemset: new_resource.ruby_gemset,

              coverage: new_resource.coverage,

              rubocop: new_resource.rubocop,
              metric_fu: new_resource.metric_fu,
              brakeman_report: new_resource.brakeman,
              rails_report: new_resource.rails,

              key_id: credentials_id,

              is_pull_request: (branch == 'pr'),
              type_tag: type_tag,
              branch_file_name: branch_file_name
  end

  jenkins_job "\(#{branch}\)\ #{new_resource.name}" do
    config config
  end

  dev_path = ::File.join(node['u2i-jenkins']['projects_dir'], new_resource.name)

  if new_resource.rails
    directory ::File.join(dev_path, 'config', branch) do
      owner 'jenkins'
      group 'jenkins'
      action :create
      recursive true
    end

    file ::File.join(dev_path, 'config', branch, 'database.yml') do
      content(database_yaml(new_resource.name, branch))
      owner 'jenkins'
      group 'jenkins'
      mode 0644
      action :create
    end
  end
end

def delete_job(branch)
  jenkins_job "\(#{branch}\)\ #{new_resource.name}" do
    action :delete
  end
end

def create_jobs
  Array(new_resource.branch).each do |branch|
    create_job(branch)
  end
end

def delete_jobs
  Array(new_resource.branch).each do |branch|
    create_job(branch)
  end
end
