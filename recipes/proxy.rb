#
# Cookbook Name:: netapp_e
# Recipe:: proxy
#
# Copyright 2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

executable_name = node['netapp']['installer']['source_url'].split('/').last

case node['platform']
when 'ubuntu', 'centos', 'redhat', 'fedora'
  # Default installation path is /opt/netapp/santricity_web_services_proxy.
  # Skip installation if this directory exists.
  return if File.directory? node['netapp']['installation_directory']

  template "#{Chef::Config[:file_cache_path]}/installer.properties" do
    source 'installer_properties.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end

  remote_file 'web_proxy' do
    source node['netapp']['installer']['source_url']
    path "#{Chef::Config[:file_cache_path]}/#{executable_name}"
    owner 'root'
    group 'root'
    mode '0777'
    action :create
  end

  bash 'install_web_proxy' do
    code "#{Chef::Config[:file_cache_path]}/#{executable_name} -f #{Chef::Config[:file_cache_path]}/installer.properties"
  end

  file "#{Chef::Config[:file_cache_path]}/#{executable_name}" do
    action :delete
  end

  file "#{Chef::Config[:file_cache_path]}/installer.properties" do
    action :delete
  end

when 'windows'
  # Default installation path is C://Program Files//NetApp//SANtricity Web Services Proxy.
  # Skip installation if this directory exists.
  return if File.directory? node['netapp']['installation_directory']

  template "#{Chef::Config[:file_cache_path]}//installer.properties" do
    source 'installer_properties.erb'
    rights :full_control, 'Everyone'
    action :create
  end

  remote_file 'web_proxy' do
    source node['netapp']['installer']['source_url']
    path "#{Chef::Config[:file_cache_path]}//#{executable_name}"
    rights :full_control, 'Everyone'
    action :create
  end

  execute 'install_web_proxy' do
    command "#{Chef::Config[:file_cache_path]}//#{executable_name} -f #{Chef::Config[:file_cache_path]}//installer.properties"
  end

  file "#{Chef::Config[:file_cache_path]}//#{executable_name}" do
    action :delete
  end

  file "#{Chef::Config[:file_cache_path]}//installer.properties" do
    action :delete
  end

end
