package 'mysql-client-5.6'
package 'libmysqlclient-dev'
include_recipe 'apt'
include_recipe 'mysql::server'

apt_repository 'gemnasium' do
  uri          'http://apt.gemnasium.com'
  distribution 'stable'
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          'E5CEAB0AC5F1CA2A'
  deb_src      false
end

package 'htop'
package 'git'
package 'tree'
package 'zsh'
package 'gemnasium-toolbelt'
