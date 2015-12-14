#
# Cookbook Name:: netapp_e
# Recipe:: volume_group
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

netapp_e_volume_group node['netapp']['volume_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  raid_level node['netapp']['volume_group']['raid_level']
  disk_drive_ids node['netapp']['volume_group']['disk_drive_id']
  erase_secured_drives node['netapp']['volume_group']['erase_secured_drives']
  action :create
end

netapp_e_volume_group node['netapp']['volume_group']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
