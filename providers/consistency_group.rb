#
# Cookbook Name:: netapp_e
# Provider:: consistency_group
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

include NetAppEHelper

action :create do
  # Validations

  request_body = { name: new_resource.name, fullWarnThresholdPercent: new_resource.full_warn_threshold_percent, autoDeleteThreshold: new_resource.auto_delete_threshold, repositoryFullPolicy: new_resource.repository_full_policy, rollbackPriority: new_resource.rollback_priority }

  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.create_consistency_group(new_resource.storage_system, request_body)
  netapp_api.logout unless node['netapp']['basic_auth']
  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  netapp_api = netapp_api_create
  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.delete_consistency_group(new_resource.storage_system, new_resource.name)
  netapp_api.logout unless node['netapp']['basic_auth']
  new_resource.updated_by_last_action(true) if resource_update_status
end
