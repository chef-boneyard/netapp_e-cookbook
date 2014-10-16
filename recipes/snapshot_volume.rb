#
# Cookbook Name:: netapp-e-series
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

netapp_e_snapshot_volume 'demo_snapshot_volume' do
  storage_system '10.250.117.112'
  snapshot_image_id '3400000060080E5000322230006303BB543F6228'
  full_threshold 0
  view_mode 'readWrite'
  repository_percentage 10000000000
  repository_pool_id '0400000060080E50003222300000025853F33C1A'

  action :create
end

netapp_e_snapshot_volume 'demo_snapshot_volume' do
  storage_system '10.250.117.112'

  action :delete
end
