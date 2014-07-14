include_recipe 'apt'
include_recipe 'rvm::system'
include_recipe 'mysql::server'
include_recipe 'mysql::client'
include_recipe 'database::mysql'

# install all required services

package 'htop'
package 'git'
package 'tree'
