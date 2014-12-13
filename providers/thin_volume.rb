#
# Cookbook Name:: netapp_e
# Provider:: thin_volume
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
  fail ArgumentError, 'Attribute pool_id is required for thin-volume creation' unless new_resource.pool_id
  fail ArgumentError, 'Attribute size_unit is required for thin-volume creation' unless new_resource.size_unit
  fail ArgumentError, 'Attribute virtual_size is required for thin-volume creation' unless new_resource.virtual_size
  fail ArgumentError, 'Attribute max_repository_size is required for thin-volume creation' unless new_resource.max_repository_size

  # HTTP Request body
  request_body = { poolId: new_resource.pool_id, name: new_resource.name, sizeUnit: new_resource.size_unit, virtualSize: new_resource.virtual_size, repositorySize: new_resource.repository_size, maximumRepositorySize: new_resource.max_repository_size, owningControllerId: new_resource.owning_controller_id, growthAlertThreshold: new_resource.growth_alert_threshold, createDefaultMapping: new_resource.create_default_mapping, expansionPolicy: new_resource.expansion_policy, cacheReadAhead: new_resource.cache_read_ahead }

  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.create_thin_volume(new_resource.storage_system, request_body)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.delete_thin_volume(new_resource.storage_system, new_resource.name)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end
