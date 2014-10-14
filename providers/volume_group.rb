#
# Cookbook Name:: netapp-e-series
# Provider:: volume_group
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

include NetAppEHelper

action :create do
  # Validations
  fail ArgumentError, 'Attribute basic_auth has to be set to true or false. It cannot be empty' unless node['netapp']['basic_auth']
  fail ArgumentError, 'Attribute raid_level is required for volume group creation' unless new_resource.raid_level
  fail ArgumentError, 'Attribute disk_drive_ids is required for volume group creation' unless new_resource.disk_drive_ids.empty?

  request_body = { raidLevel: new_resource.raid_level, diskDriveIds: new_resource.disk_drive_ids, name: new_resource.name }

  netapp_api = NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'], node['netapp']['api']['timeout'])

  resource_update_status = netapp_api.create_volume_group(new_resource.storage_system, request_body)

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  # Validations
  fail ArgumentError, 'Attribute basic_auth has to be set to true or false. It cannot be empty' unless node['netapp']['basic_auth']

  netapp_api = NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'], node['netapp']['api']['timeout'])

  resource_update_status = netapp_api.delete_volume_group(new_resource.storage_system, new_resource.name)

  new_resource.updated_by_last_action(true) if resource_update_status
end
