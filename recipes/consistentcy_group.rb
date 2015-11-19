# Cookbook Name:: netapp_e
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
#

netapp_e_consistentcy_group 'my_consistency_group' do
  storage_system '10.250.117.112'

  action :create
end

netapp_e_consistentcy_group 'my_consistency_group' do
  storage_system '10.250.117.112'

  action :delete
end
