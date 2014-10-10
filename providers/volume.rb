#
# Cookbook Name:: netapp-e-series
# Provider:: volume
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
  # validations
  raise ArgumentError, "Attribute pool_id is required for volume creation" unless new_resource.pool_id
  raise ArgumentError, "Attribute size_unit is required for volume creation" unless new_resource.size_unit
  raise ArgumentError, "Attribute size is required for volume creation" unless new_resource.size
  raise ArgumentError, "Attribute segment_size is required for volume creation" unless new_resource.segment_size

  netapp_api = NetApp::ESeries::Api.new(url, new_resource.storage_system)

  netapp_api.login(node['netapp']['user'], node['netapp']['password'])
  resource_update_status = netapp_api.create_volume(new_resource.pool_id, new_resource.name, new_resource.size_unit, new_resource.size, new_resource.segment_size)
  netapp_api.logout(node['netapp']['user'], node['netapp']['password'])

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  netapp_api = NetApp::ESeries::Api.new(url, new_resource.storage_system)

  netapp_api.login(node['netapp']['user'], node['netapp']['password'])
  resource_update_status = netapp_api.delete_volume(new_resource.name)
  netapp_api.logout(node['netapp']['user'], node['netapp']['password'])

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :update do
  # validations
  raise ArgumentError, "Attribute new_name is required to update volume name" unless new_resource.new_name

  netapp_api = NetApp::ESeries::Api.new(url, new_resource.storage_system)

  netapp_api.login(node['netapp']['user'], node['netapp']['password'])
  resource_update_status = netapp_api.update_volume(new_resource.name, new_resource.new_name)
  netapp_api.logout(node['netapp']['user'], node['netapp']['password'])

  new_resource.updated_by_last_action(true) if resource_update_status
end
