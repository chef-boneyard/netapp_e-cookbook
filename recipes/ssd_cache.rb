#
# Cookbook Name:: netapp_e
# Recipe:: ssd_cache
#
# Copyright 2015, Chef Software, Inc.
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

netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  name node['netapp']['ssd_cache']['name']
  enable_existing_volumes node['netapp']['ssd_cache']['enable_existing_volumes']
  drive_refs node['netapp']['ssd_cache']['drive_refs']
  action :create
end

netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  drive_refs node['netapp']['ssd_cache']['drive_refs']
  action :update
end

netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  action :suspend
end

netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  action :resume
end

netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  action :delete
end
