#
# Cookbook Name:: netapp_e
# Provider:: network_configuration
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

action :update do
  request_body = { controllerRef: new_resource.controller_ref, interfaceRef: new_resource.interface_ref }

  new_resource.update_parameters.each do |key, value|
    request_body[key] = value if new_resource.update_parameters[key] != ''
  end
  netapp_api = netapp_api_create
  netapp_api.login unless node['netapp']['basic_auth']
  resource_update_status = netapp_api.update_network_configuration(new_resource.storage_system, request_body)
  netapp_api.logout unless node['netapp']['basic_auth']

  new_resource.updated_by_last_action(true) if resource_update_status
end
