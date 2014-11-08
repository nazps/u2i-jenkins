#
# Cookbook Name:: u2i-jenkins
# Recipe:: default
#
# Copyright (C) 2014 Michał Knapik
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'u2i-jenkins::_rvm'
include_recipe 'u2i-jenkins::jenkins'
include_recipe 'u2i-jenkins::services'
include_recipe 'u2i-jenkins::jobs'

restart_required = false

ruby_block 'jenkins_service_restart_flag' do
  block do
    restart_required = true
  end
  action :nothing
end

service 'jenkins' do
  action :restart
  only_if { restart_required }
end
