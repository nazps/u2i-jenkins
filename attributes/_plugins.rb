plugins = %w(violations github ghprb categorized-view htmlpublisher postbuild-task ssh-agent ruby
rvm rubyMetrics openid ws-cleanup email-ext envinject
embeddable-build-status build-monitor-plugin matrix-project ansicolor warnings)
plugin_deps = %w(mailer git promoted-builds credentials token-macro git-client multiple-scms parameterized-trigger
scm-api ssh-credentials github-api conditional-buildstep run-condition maven-plugin ruby-runtime rake
javadoc xunit ivy subversion ssh-slaves translation windows-slaves pam-auth matrix-auth ldap ant cvs
external-monitor-job analysis-core config-file-provider openid4java gravatar jquery)
disable = %w(cvs subversion translation ant external-monitor-job windows-slaves)

default['u2i-jenkins']['plugins']['install'] = plugin_deps + plugins
default['u2i-jenkins']['plugins']['disable'] = disable
