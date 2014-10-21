#
# Cookbook Name:: netapp-e-series
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

# To do
# Test the recipe. web proxy msi installer required for testing on widnows machine.

case node['platform']
when 'ubuntu', 'centos', 'redhat', 'fedora'
  remote_file 'web_proxy' do
    source 'http://fqdn/webservice-01.00.7000.0003.bin'
    path '/tmp/web_proxy.bin'
    mode '0777'
    action :create
  end

  bash '/tmp/web_proxy.bin -i silent'

  file '/tmp/web_proxy.bin' do
    action :delete
  end
when 'windows'
  remote_file 'web_proxy' do
    source 'http://fqdn/webservice-01.00.7000.0003.msi'
    path '%Temp%/web_proxy.msi'
    mode '0777'
    action :create
  end

  batch 'msiexec web_proxy.msi /quiet'

  file '%Temp%/web_proxy.msi' do
    action :delete
  end
end
