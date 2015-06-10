require 'securerandom'
require 'active_support/core_ext'

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
  if @new_resource.type == :matrix
    if !defined?(@new_resource.matrix) || @new_resource.matrix.nil?
      fail 'Missing matrix attribute for matrix project'
    end
  end
  @current_resource = Chef::Resource::U2iJenkinsJob.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.lang(@new_resource.lang)
  @current_resource.rubocop(node['u2i-jenkins']['config']['plugins']['rubocop']['default'].deep_merge(@new_resource.rubocop))
  if @new_resource.coverage
    @current_resource.coverage(node['u2i-jenkins']['config']['plugins']['coverage']['default'].deep_merge(@new_resource.coverage))
  else
    @current_resource.coverage(false)
  end

  if @new_resource.lang == :ruby
    @current_resource.checkstyle(false)
    @current_resource.pmd(false)
    @current_resource.findbugs(false)
  elsif @new_resource.lang == :java
    @current_resource.rubocop(false)
    @current_resource.metric_fu(false)
    @current_resource.brakeman(false)
    @current_resource.rails(false)
    @current_resource.custom_db(false)
    @current_resource.rails_adapter(nil)
  end
end

private

def escape_slash(branch)
  branch.gsub('/', '_')
end

def create_job(branch)
  if new_resource.key
    h = new_resource.key.dup
    credential_name, credential_config = h.keys.first, h[h.keys.first]
    credentials = jenkins_private_key_credentials credential_name.dup do
      description credential_config['description'].dup if credential_name['description']
      private_key credential_config['private_key'].dup
      id credential_config['id'].dup
    end
    credentials_id = credentials.id
  elsif new_resource.key_id
    credentials_id = new_resource.key_id
  else
    credentials_id = nil
  end

  type_tag = case @new_resource.type
               when :freestyle
                 'project'
               when :matrix
                 'matrix-project'
             end

  branch_file_name = branch.gsub('/', '__')
  config = ::File.join(Chef::Config[:file_cache_path], "#{new_resource.name}_#{branch_file_name}.config.xml")

  builders = new_resource.builders

  if @new_resource.lang == :ruby
    rvm_setup = "set +x\nsource $RVM_HOME/scripts/rvm\nrvm use ${JOB_RUBY_VERSION}@${JOB_RUBY_GEMSET} --create --install\nset -x"

    builders = builders.map do |builder|
      if builder.key?('hudson.tasks.Shell')
        {
          'hudson.tasks.Shell' => {
            'command' => [rvm_setup, builder['hudson.tasks.Shell']['command']].join("\n")
          }
        }
      else
        builder
      end
    end
  end

  builders = builders.flat_map do |builder|
    builder.map do |k, v|
      v.to_xml(root: k, skip_instruct: true).split("\n").map do |l|
        (l.start_with?('<') ? '    ' : '') + l
      end.join("\n")
    end
  end

  template config do
    source 'jenkins/job.config.xml.erb'
    variables project_name: new_resource.name,
              repository: new_resource.repository,
              branch: branch,
              builders: builders,
              concurrent_build: new_resource.concurrent_build,

              description: new_resource.description,

              timer_trigger: new_resource.timer_trigger,
              type: new_resource.type,
              lang: new_resource.lang,
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
              gemnasium_token: new_resource.gemnasium_token,
              gemnasium_project_slug: new_resource.gemnasium_project_slugs[branch],

              env_inject: new_resource.env_inject,

              checkstyle: new_resource.checkstyle,
              pmd: new_resource.pmd,
              findbugs: new_resource.findbugs,

              key_id: credentials_id,

              is_pull_request: (branch == 'pr'),
              type_tag: type_tag,
              branch_file_name: branch_file_name
    cookbook 'u2i-jenkins'
  end

  jenkins_job "\(#{escape_slash(branch)}\)\ #{new_resource.name}" do
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

    unless new_resource.custom_db
      file ::File.join(dev_path, 'config', 'database.yml') do
        content(database_yaml(new_resource.rails_adapter))
        owner 'jenkins'
        group 'jenkins'
        mode 0644
        action :create
      end
    end
  end
end

def delete_job(branch)
  jenkins_job "\(#{escape_slash(branch)}\)\ #{new_resource.name}" do
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
