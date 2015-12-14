#
# Cookbook Name:: netapp_e
# Recipe:: volume_copy
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

netapp_e_volume_copy node['netapp']['storage_system_ip'] do
  source_id node['netapp']['volume_copy']['source_id']
  target_id node['netapp']['volume_copy']['target_id']
  copy_priority node['netapp']['volume_copy']['copy_priority']
  target_write_protected node['netapp']['volume_copy']['target_write_protected']
  online_copy node['netapp']['volume_copy']['online_copy']
  action :create
end

netapp_e_volume_copy node['netapp']['volume_copy']['vc_id'] do
  storage_system node['netapp']['storage_system_ip']
  action :delete
end
