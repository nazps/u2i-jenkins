node['u2i-jenkins']['slaves'].each do |slave, config|
  jenkins_ssh_slave 'executor' do
    description 'Run test suites'
    remote_fs '/share/executor'
    labels %w(executor)

    # SSH specific attributes
    host config['host'] # or 'slave.example.org'
    user 'jenkins'
    credentials 'wcoyote'
  end
end
