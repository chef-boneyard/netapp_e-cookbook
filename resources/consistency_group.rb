#
# cookbook Name:: netapp_e
# Resource:: consistency_group
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
attribute :full_warn_threshold_percent, kind_of: Integer, default: 75
attribute :auto_delete_threshold, kind_of: Integer, default: 32
attribute :repository_full_policy, kind_of: String, default: 'purgepit'
attribute :rollback_priority, kind_of: String, default: 'highest'
