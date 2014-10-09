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

include NetApp::Api

action :create do
  login(node['netapp']['user'], node['netapp']['password'])
  resource_update = add_storage_system(new_resource.name)
  logout(node['netapp']['user'], node['netapp']['password'])
  new_resource.updated_by_last_action(true) if resource_update
end

action :delete do
  login(node['netapp']['user'], node['netapp']['password'])
  resource_update = remove_storage_system(new_resource.name)
  logout(node['netapp']['user'], node['netapp']['password'])
  new_resource.updated_by_last_action(true) if resource_update
end
