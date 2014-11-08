plugins = %w(violations github ghprb categorized-view htmlpublisher postbuild-task ssh-agent ruby
             rvm rubyMetrics openid ws-cleanup email-ext envinject
             embeddable-build-status build-monitor-plugin matrix-project ansicolor warnings
             buildtriggerbadge brakeman)
disable = %w(cvs subversion translation ant external-monitor-job windows-slaves)

default['u2i-jenkins']['plugins']['install'] = plugins
default['u2i-jenkins']['plugins']['disable'] = disable
