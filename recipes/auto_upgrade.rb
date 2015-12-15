#
# Cookbook Name:: netapp_e
# Recipe:: auto_upgrade
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
::Chef::Recipe.send(:include, NetAppEHelper)

netapp_api = netapp_api_create
netapp_api.login unless node['netapp']['basic_auth']
netapp_api.web_proxy_update
netapp_api.logout unless node['netapp']['basic_auth']
