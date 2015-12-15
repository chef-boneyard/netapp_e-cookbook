#
# Cookbook Name:: netapp_e
# Provider:: mirror_group
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
  fail ArgumentError, 'Attribute secondary_array_id is required for mirror group creation' unless new_resource.secondary_array_id

  request_body = { secondaryArrayId: new_resource.secondary_array_id, name: new_resource.name, syncIntervalMinutes: new_resource.sync_interval_minutes, manualSync: new_resource.manual_sync, recoveryWarnThresholdMinutes: new_resource.recovery_warn_threshold_minutes, repoUtilizationWarnThreshold: new_resource.repo_utilization_warn_threshold, syncWarnThresholdMinutes: new_resource.syncWarn_threshold_minutes }

  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.create_mirror_group(new_resource.storage_system, request_body)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.delete_mirror_group(new_resource.storage_system, new_resource.name)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end
