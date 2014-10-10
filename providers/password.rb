#
# Cookbook Name:: netapp-e-series
# Provider:: password
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
  netapp_api = NetApp::ESeries::Api.new(url, new_resource.name)

  netapp_api.login(node['netapp']['user'], node['netapp']['password'])
  resource_update_status = netapp_api.change_password(new_resource.current_admin_password, new_resource.admin_password, new_resource.new_password)
  netapp_api.logout(node['netapp']['user'], node['netapp']['password'])

  new_resource.updated_by_last_action(true) if resource_update_status
end
