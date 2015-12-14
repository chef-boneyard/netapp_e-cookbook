#
# Cookbook Name:: netapp_e
# Recipe:: host
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
netapp_e_host node['netapp']['host']['name'] do
  storage_system node['netapp']['storage_system_ip']
  host_default node['netapp']['host']['host_default']
  code node['netapp']['host']['code']
  host_used node['netapp']['host']['host_used']
  index node['netapp']['host']['index']
  host_type_name node['netapp']['host']['host_type_name']
  ports node['netapp']['host']['ports']
  group_id node['netapp']['host']['groupid']

  action :create
end

netapp_e_host node['netapp']['host']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
