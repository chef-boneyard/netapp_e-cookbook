#
# Cookbook Name:: netapp_e
# Recipe:: volume
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

netapp_e_volume node['netapp']['volume']['name'] do
  storage_system node['netapp']['storage_system_ip']
  pool_id node['netapp']['volume']['pool_id']
  size_unit node['netapp']['volume']['size_unit']
  size node['netapp']['volume']['size']
  segment_size node['netapp']['volume']['segment_size']
  data_assurance_enabled node['netapp']['volume']['data_assurance_enabled']
  action :create
end

netapp_e_volume node['netapp']['volume']['name'] do
  storage_system node['netapp']['storage_system_ip']
  new_name 'my_vol2'
  action :update
end

netapp_e_volume node['netapp']['volume']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
