#
# Cookbook Name:: netapp_e
# Provider:: ssd_cache
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
  fail ArugumentError 'Attribute drive_refs is required for ssd_cache creation' unless new_resource.drive_refs

  request_body = { driveRefs: new_resource.drive_refs, name: new_resource.name,
                   enableExistingVolumes: new_resource.enable_existing_volumes }

  netapp_api = netapp_api_create

  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.create_ssd_cache(new_resource.storage_system, request_body)

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  netapp_api = netapp_api_create
  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.delete_ssd_cache(new_resource.storage_system)

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :update do
  # Validations
  fail ArugumentError 'Attribute drive_refs is required for ssd_cache creation' unless new_resource.drive_refs

  request_body = { driveRef: new_resource.drive_refs }

  netapp_api = netapp_api_create
  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.update_ssd_cache(new_resource.storage_system, request_body)

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :resume do
  netapp_api = netapp_api_create
  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.resume_ssd_cache(new_resource.storage_system)

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :suspend do
  netapp_api = netapp_api_create
  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.suspend_ssd_cache(new_resource.storage_system)

  new_resource.updated_by_last_action(true) if resource_update_status
end
