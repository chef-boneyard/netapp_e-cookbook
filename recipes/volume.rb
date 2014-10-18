#
# Cookbook Name:: netapp-e-series
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

netapp_e_volume 'myvol1' do
  storage_system '10.250.117.112'
  pool_id '0400000060080E50003220A80000006F52D8010D'
  size_unit 'b'
  size 100
  segment_size 0

  action :create
end

netapp_e_volume 'myvol1' do
  storage_system '10.250.117.112'
  new_name 'myvol2'

  action :update
end

netapp_e_volume 'myvol2' do
  storage_system '10.250.117.112'

  action :delete
end
