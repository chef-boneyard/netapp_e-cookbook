#
# Cookbook Name:: netapp-e-series
# Provider:: snapshot_volume
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

action :create do
  # Validations
  fail ArgumentError, 'Attribute raid_level is required for volume creation' unless new_resource.raid_level
  fail ArgumentError, 'Attribute raid_level is required for volume creation' unless new_resource.disk_drive_ids.empty?

  netapp_api = NetApp::ESeries::Api.new(url, new_resource.storage_system)

  netapp_api.login(node['netapp']['user'], node['netapp']['password'])
  resource_update_status = netapp_api.create_storage_pool(new_resource.raid_level, new_resource.disk_drive_ids, new_resource.name)
  netapp_api.logout(node['netapp']['user'], node['netapp']['password'])

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  netapp_api = NetApp::ESeries::Api.new(url, new_resource.storage_system)

  netapp_api.login(node['netapp']['user'], node['netapp']['password'])
  resource_update_status = netapp_api.delete_storage_pool(new_resource.name)
  netapp_api.logout(node['netapp']['user'], node['netapp']['password'])

  new_resource.updated_by_last_action(true) if resource_update_status
end
