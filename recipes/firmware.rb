#
# Cookbook Name:: netapp_e
# Recipe:: firmware
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

netapp_e_firmware node['netapp']['storage_system_ip'] do
  cfw_file node['netapp']['firmware']['cfw_file']
  nvsram_file node['netapp']['firmware']['nvsram_file']
  stage_firmware node['netapp']['firmware']['stage_firmware']
  skip_mel_check node['netapp']['firmware']['skip_mel_check']

  action :upgrade
end
