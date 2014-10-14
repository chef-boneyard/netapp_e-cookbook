#
# Cookbook Name:: netapp-e-series
# Provider:: host
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
  fail ArgumentError, 'Attribute basic_auth has to be set to true or false. It cannot be empty' unless node['netapp']['basic_auth']
  fail ArgumentError, 'Attribute host_default is required for host creation' unless new_resource.host_default
  fail ArgumentError, 'Attribute code is required for host creation' unless new_resource.code
  fail ArgumentError, 'Attribute host_used is required for host creation' unless new_resource.host_used
  fail ArgumentError, 'Attribute index is required for host creation' unless new_resource.index
  fail ArgumentError, 'Attribute host_type_name is required for host creation' unless new_resource.host_type_name

  # HTTP Request body
  host_type = { default: new_resource.host_default, code: new_resource.code, used: new_resource.host_used, index: new_resource.index, name: new_resource.host_type_name }
  request_body = { name: new_resource.name, hostType: host_type, groupId: new_resource.group_id, ports: new_resource.ports }

  netapp_api = NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'], node['netapp']['api']['timeout'])

  resource_update_status = netapp_api.create_host(new_resource.storage_system, request_body)

  new_resource.updated_by_last_action(true) if resource_update_status
end

action :delete do
  # Validations
  fail ArgumentError, 'Attribute basic_auth has to be set to true or false. It cannot be empty' unless node['netapp']['basic_auth']

  netapp_api = NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'], node['netapp']['api']['timeout'])

  resource_update_status = netapp_api.delete_host(new_resource.storage_system, new_resource.name)

  new_resource.updated_by_last_action(true) if resource_update_status
end
