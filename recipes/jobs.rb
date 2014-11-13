node['u2i-jenkins']['jobs'].each do |jobname, config|
  if config['recipe'].nil?
    keys = Chef::EncryptedDataBagItem.load('keys', 'jenkins')

    u2i_jenkins_job jobname do
      repository config['repository']
      branch config['branches']
      builders config['builders']

      type config['type'].to_sym if config['type']
      matrix config['matrix'] if [:ruby_matrix, 'ruby_matrix'].include? config['type']
      ws_cleanup config['ws_cleanup'] if config['ws_cleanup']
      keep_builds config['keep_builds'] if config['keep_builds']

      git_recursive config['git_recursive'] if config['git_recursive']

      ruby_version config['ruby_version'] if config['ruby_version']
      ruby_gemset config['ruby_gemset'] if config['ruby_gemset']

      coverage config['coverage'] if config['coverage']

      rubocop config['rubocop'] if config['rubocop']
      metric_fu config['metric_fu'] if config['metric_fu']
      brakeman config['brakeman'] if config['brakeman']
      rails config['rails'] if config['rails']

      key keys['credentials'][config['credential_name'] || jobname]['private_key'] if config['credential_name']
    end
  else
    include_recipe config['recipe']
  end
end

jenkins_command 'reload-configuration'
