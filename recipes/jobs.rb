node['u2i-jenkins']['jobs'].each do |jobname, config|
  if config['recipe'].nil?
    keys = Chef::EncryptedDataBagItem.load('keys', 'jenkins')
    credential_name = config['credential_name'] || jobname

    u2i_jenkins_job jobname do
      repository config['repository']
      branch config['branches']
      builders config['builders']

      description config['description'] unless config['description'].blank?

      concurrent_build config['concurrent_build'] unless config['concurrent_build'].nil?
      type config['type'].to_sym if config['type']
      lang config['lang'].to_sym if config['lang']
      matrix config['matrix'] if [:matrix, 'matrix'].include? config['type']
      ws_cleanup config['ws_cleanup'] unless config['ws_cleanup'].nil?
      keep_builds config['keep_builds'] unless config['keep_builds'].nil?

      git_recursive config['git_recursive'] unless config['git_recursive'].nil?

      ruby_version config['ruby_version'] if config['ruby_version']
      ruby_gemset config['ruby_gemset'] if config['ruby_gemset']

      coverage config['coverage'] if config['coverage']

      rubocop config['rubocop'] unless config['rubocop'].nil?
      metric_fu config['metric_fu'] unless config['metric_fu'].nil?
      brakeman config['brakeman'] unless config['brakeman'].nil?
      rails config['rails'] unless config['rails'].nil?
      rails_adapter config['rails_adapter'] unless config['rails_adapter']
      custom_db config['custom_db'] unless config['custom_db'].nil?

      unless keys['Gemnasium'].nil? || keys['Gemnasium']['projectSlugs'][jobname].nil?
        gemnasium_token keys['Gemnasium']['accessToken']
        gemnasium_project_slugs keys['Gemnasium']['projectSlugs'][jobname]
      end
      github_token keys['Github']['access_token'] unless keys['Github'].nil?

      env_inject config['env_inject'] unless config['env_inject'].nil?

      key({credential_name => keys['credentials'][credential_name]})
    end
  end
end

jenkins_command 'reload-configuration'
