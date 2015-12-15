#
# Cookbook Name:: netapp_e
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
  fail ArgumentError, 'Attribute pool_id is required for volume creation' unless new_resource.pool_id
  fail ArgumentError, 'Attribute size_unit is required for volume creation' unless new_resource.size_unit
  fail ArgumentError, 'Attribute size is required for volume creation' unless new_resource.size
  fail ArgumentError, 'Attribute segment_size is required for volume creation' unless new_resource.segment_size

  request_body = { poolId: new_resource.pool_id, name: new_resource.name, sizeUnit: new_resource.size_unit, size: new_resource.size, segSize: new_resource.segment_size, dataAssuranceEnabled: new_resource.data_assurance_enabled }

  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.create_volume(new_resource.storage_system, request_body)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.delete_volume(new_resource.storage_system, new_resource.name)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :update do
  # validations
  fail ArgumentError, 'Attribute new_name is required to update volume name' unless new_resource.new_name

  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.update_volume(new_resource.storage_system, new_resource.name, new_resource.new_name)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end
