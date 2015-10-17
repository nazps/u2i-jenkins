include_recipe 'apt'

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
