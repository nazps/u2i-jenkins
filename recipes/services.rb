include_recipe 'apt'
include_recipe 'mysql::server'
include_recipe 'mysql::client'
include_recipe 'database::mysql'

package 'htop'
package 'git'
package 'tree'
package 'zsh'
