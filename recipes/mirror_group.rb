#
# Cookbook Name:: netapp_e
# Recipe:: mirror_group
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

netapp_e_mirror_group node['netapp']['mirror_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  secondary_array_id node['netapp']['mirror_group']['secondary_array_id']
  sync_interval_minutes node['netapp']['mirror_group']['sync_interval_minutes']
  manual_sync node['netapp']['mirror_group']['manual_sync']
  recovery_warn_threshold_minutes node['netapp']['mirror_group']['recovery_warn_threshold_minutes']
  repo_utilization_warn_threshold node['netapp']['mirror_group']['repo_utilization_warn_threshold']
  syncWarn_threshold_minutes node['netapp']['mirror_group']['syncWarn_threshold_minutes']
  action :create
end

netapp_e_mirror_group node['netapp']['mirror_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  action :delete
end
