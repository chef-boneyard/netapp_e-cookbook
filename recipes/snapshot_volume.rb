#
# Cookbook Name:: netapp_e
# Recipe:: snapshot_volume
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

netapp_e_snapshot_volume node['netapp']['snapshot_volume']['name'] do
  storage_system node['netapp']['storage_system_ip']
  snapshot_image_id node['netapp']['snapshot_volume']['snapshot_image_id']
  full_threshold node['netapp']['snapshot_volume']['full_threshold']
  view_mode node['netapp']['snapshot_volume']['view_mode']
  repository_percentage node['netapp']['snapshot_volume']['repository_percentage']
  repository_pool_id node['netapp']['snapshot_volume']['repository_pool_id']

  action :create
end

netapp_e_snapshot_volume node['netapp']['snapshot_volume']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
