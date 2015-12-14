#
# Cookbook Name:: netapp_e
# Recipe:: network_configuration
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

netapp_e_network_configuration node['netapp']['storage_system_ip'] do
  controller_ref node['netapp']['network_configuration']['controller_ref']
  interface_ref node['netapp']['network_configuration']['interface_ref']
  update_parameters node.default['netapp']['network_configuration']['update_parameters']

  action :update
end
