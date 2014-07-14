#
# Cookbook Name:: u2i-jenkins
# Recipe:: default
#
# Copyright (C) 2014 Michał Knapik
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'u2i-jenkins::services'
include_recipe 'u2i-jenkins::jenkins'
include_recipe 'u2i-jenkins::jobs'

jenkins_command 'reload-configuration'
