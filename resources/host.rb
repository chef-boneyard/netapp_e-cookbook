#
# Cookbook Name:: netapp-e-series
# Resource:: host
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

actions :create, :delete
default_action :create

attribute :name, kind_of: String, required: true, name_attribute: true
attribute :storage_system, kind_of: String, required: true

attribute :group_id, kind_of: String
attribute :ports, kind_of: Array

# Host Type
attribute :host_default, kind_of: [TrueClass, FalseClass]
attribute :code, kind_of: String
attribute :host_used, kind_of: [TrueClass, FalseClass]
attribute :index, kind_of: Integer
attribute :host_type_name, kind_of: String
