#
# Cookbook Name:: netapp-e-series
# Recipe:: disk_pool
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

netapp_e_disk_pool 'demo_disk_pool' do
  storage_system '10.250.117.112'
  disk_drive_ids %w(010000005000C5004B993D9B0000000000000000 010000005000CCA016B152540000000000000000 010000005000CCA016B19B600000000000000000 010000005000CCA016B2BCB00000000000000000 010000005000CCA016B2F5FC0000000000000000 010000005000CCA016B3B0980000000000000000 010000005000CCA0225C24B80000000000000000 010000005000CCA0225CD88C0000000000000000 010000005000CCA0225F50100000000000000000 010000005000CCA02260F2EC0000000000000000 010000005000CCA02260F3080000000000000000)

  action :create
end

netapp_e_disk_pool 'demo_disk_pool' do
  storage_system '10.250.117.112'

  action :delete
end
