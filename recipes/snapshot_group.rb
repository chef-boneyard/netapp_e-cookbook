#
# Cookbook Name:: netapp_e
# Recipe:: snapshot_group
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

netapp_e_snapshot_group node['netapp']['snapshot_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  base_mappable_object_id node['netapp']['snapshot_group']['base_mappable_object_id']
  repository_percentage node['netapp']['snapshot_group']['repository_percentage']
  warning_threshold node['netapp']['snapshot_group']['warning_threshold']
  auto_delete_limit node['netapp']['snapshot_group']['auto_delete_limit']
  full_policy node['netapp']['snapshot_group']['full_policy']
  storage_pool_id node['netapp']['snapshot_group']['storage_pool_id']

  action :create
end

netapp_e_snapshot_group node['netapp']['snapshot_group']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
