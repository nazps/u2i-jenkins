name             'u2i-jenkins'
maintainer       'Michal Knapik'
maintainer_email 'michal.knapik@u2i.com'
license          'All rights reserved'
description      'Installs/Configures u2i-jenkins'
long_description 'Installs/Configures u2i-jenkins'
version          '0.4.4'

depends 'java', '~> 1.29.0'
depends 'apache2', '~> 2.0.0'
depends 'jenkins', '~> 2.2.2'
depends 'rvm', '~> 0.9.2'
depends 'database', '~> 2.3.0'
depends 'mysql', '~> 5.6.1'
depends 'ssh_known_hosts', '~> 2.0.0'
depends 'apt', '~> 2.6.1'
depends 'maven', '~> 1.2.0'

supports 'ubuntu'
