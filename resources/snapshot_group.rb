#
# Cookbook Name:: netapp_e
# Resource:: snapshot_group
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

attribute :base_mappable_object_id, kind_of: String
attribute :repository_percentage, kind_of: Integer
attribute :warning_threshold, kind_of: Integer
attribute :auto_delete_limit, kind_of: Integer
attribute :full_policy, kind_of: String, equal_to: %w(unknown failbasewrites purgepit)
attribute :storage_pool_id, kind_of: String
