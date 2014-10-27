#
# Cookbook Name:: netapp-e-series
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

netapp_e_snapshot_group 'demo_snapshot_group' do
  storage_system '10.250.117.112'
  base_mappable_object_id '0200000060080E500032223000000388543E09C1'
  repository_percentage 10_000_000_000
  warning_threshold 0
  auto_delete_limit 32
  full_policy 'failbasewrites'
  storage_pool_id '0400000060080E50003220A80000006F52D8010D'

  action :create
end

netapp_e_snapshot_group 'demo_snapshot_group' do
  storage_system '10.250.117.112'

  action :delete
end
