#
# Cookbook Name:: netapp_e
# Resource:: mirror_group
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

actions :create, :delete
default_action :create

attribute :name, kind_of: String, required: true, name_attribute: true
attribute :storage_system, kind_of: String, required: true

attribute :secondary_array_id, kind_of: String, required: true
attribute :sync_interval_minutes, kind_of: Integer, default: 10
attribute :manual_sync, kind_of: [TrueClass, FalseClass], default: false
attribute :recovery_warn_threshold_minutes, kind_of: Integer, default: 20
attribute :repo_utilization_warn_threshold, kind_of: Integer, default: 80
attribute :syncWarn_threshold_minutes, kind_of: Integer, default: 10
