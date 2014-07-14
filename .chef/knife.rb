current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                'u2i-jenkins'
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
data_bag_path            'test/integration/data_bags'

knife[:secret_file] = '.chef/encrypted_data_bag_secret'
