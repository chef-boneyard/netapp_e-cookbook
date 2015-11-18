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

case node['platform']
when 'ubuntu', 'centos', 'redhat', 'fedora'
  # Default installation path is /opt/netapp/ . Skip installation if this directory exists.
  return if File.directory? '/opt/netapp/'

  remote_file 'web_proxy' do
    source 'https://example.com/webservice-01.30.7000.0002.bin'
    path '/tmp/webservice-01.30.7000.0002.bin'
    mode '0777'
    action :create
  end

  cookbook_file '/tmp/installer.properties' do
    source 'linux_installer.properties'
    owner 'root'
    group 'root'
    mode '0777'
    action :create
  end

  bash 'install_web_proxy' do
    code '/tmp/webservice-01.30.7000.0002.bin -f /tmp/installer.properties'
  end

  file '/tmp/webservice-01.30.7000.0002.bin' do
    action :delete
  end

  file '/tmp/installer.properties' do
    action :delete
  end

end

