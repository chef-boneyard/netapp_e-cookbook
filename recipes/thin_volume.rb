#
# Cookbook Name:: netapp_e
# Recipe:: thin_volume
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

netapp_e_thin_volume node['netapp']['thin_volume']['name'] do
  storage_system node['netapp']['storage_system_ip']
  pool_id node['netapp']['thin_volume']['pool_id']
  size_unit node['netapp']['thin_volume']['size_unit']
  virtual_size node['netapp']['thin_volume']['virtual_size']
  repository_size node['netapp']['thin_volume']['repository_size']
  max_repository_size node['netapp']['thin_volume']['max_repository_size']

  action :create
end

netapp_e_thin_volume node['netapp']['thin_volume']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
