# Cookbook Name:: netapp_e
# Recipe:: consistency_group
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
#
netapp_e_consistency_group node['netapp']['consistency_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  full_warn_threshold_percent node['netapp']['consistency_group']['full_warn_threshold_percent']
  auto_delete_threshold node['netapp']['consistency_group']['auto_delete_threshold']
  repository_full_policy node['netapp']['consistency_group']['repository_full_policy']
  rollback_priority node['netapp']['consistency_group']['rollback_priority']

  action :create
end

netapp_e_consistency_group node['netapp']['consistency_group']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
