#
# Cookbook Name:: netapp_e
# Provider:: snapshot_group
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
  fail ArgumentError, 'Attribute base_mappable_object_id is required to create group snapshot creation' unless new_resource.base_mappable_object_id
  fail ArgumentError, 'Attribute repository_percentage is required to create group snapshot creation' unless new_resource.repository_percentage
  fail ArgumentError, 'Attribute warning_threshold is required to create group snapshot creation' unless new_resource.warning_threshold
  fail ArgumentError, 'Attribute auto_delete_limit is required to create group snapshot creation' unless new_resource.auto_delete_limit
  fail ArgumentError, 'Attribute full_policy is required to create group snapshot creation' unless new_resource.full_policy
  fail ArgumentError, 'Attribute storage_pool_id is required to create group snapshot creation' unless new_resource.storage_pool_id

  request_body = { baseMappableObjectId: new_resource.base_mappable_object_id, name: new_resource.name, repositoryPercentage: new_resource.repository_percentage, warningThreshold: new_resource.warning_threshold, autoDeleteLimit: new_resource.auto_delete_limit, fullPolicy: new_resource.full_policy, storagePoolId: new_resource.storage_pool_id }

  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.create_group_snapshot(new_resource.storage_system, request_body)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.delete_group_snapshot(new_resource.storage_system, new_resource.name)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end
