#
# Cookbook Name:: netapp_e
# Resource:: firmware
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

actions :upgrade
default_action :upgrade

attribute :storage_system, kind_of: String, required: true

attribute :cfw_file, kind_of: String
attribute :nvsram_file, kind_of: String
attribute :stage_firmware, kind_of: [TrueClass, FalseClass]
attribute :skip_mel_check, kind_of: [TrueClass, FalseClass]
