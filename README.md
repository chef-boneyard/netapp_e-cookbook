NetApp E-Series Cookbook
========================

The NetApp E-Series cookbook manages E-Series storage arrays using the NetApp SANtricity Web Services Proxy.
https://library.netapp.com/ecm/ecm_download_file/ECMP1394573

Requirements
------------
#### NetApp SANtricity Web Services Proxy

You may download it from [NetApp](http://mysupport.netapp.com/NOW/download/software/eseries_webservices/1.0/) after you have created an account on [NetApp NOW](https://support.netapp.com/eservice/public/now.do). You may install it manually or use the `proxy` recipe.

You need to rename the directory to netapp_e from netapp_e-cookbook in order to use the resources.

NetApp E-Series connection
-----------------
The connection is made over HTTPS through the SANtricity Web Services Proxy and the connection settings are managed by attributes.

    ['netapp']['https'] boolean
    ['netapp']['user'] string
    ['netapp']['password'] string
    ['netapp']['fqdn'] string
    ['netapp']['basic_auth'] boolean

You can optionally provide the web proxy port and http timeout by providing the attributes port and timeout respectively.

    ['netapp']['port'] string
    ['netapp']['timeout'] integer

You need to have the necessary certificates in the environment path of machine if you are using https for the connection with the web proxy.

NetApp E-Series Recipes
=======================

proxy
-----
This recipe will install the SANtricity proxy service on Red Hat Linux 6. It doesn't support windows installation currently. It is unavailable for direct download from NetApp's website so you will need to mirror it locally and provide this URL as an attribute.

NetApp SANtricity Web Services Proxy 1.0	64-bit Linux	103 MB	webservice-01.00.7000.0003.bin

https://www.youtube.com/watch?v=MINP9nJ5r_g&list=UUoYBmy2WT8nQWn9WpOiwKWg

NetApp E-Series Resources
================

Common Attributes
-----------------
In addition to those provided by Chef itself (`ignore_failure`, `retries`, `retry_delay`, etc.), the connection attribute(s) are exposed all NetApp E-Series Resources even though they are typically set by attributes.

Common Actions
--------------
The `:nothing` action is provided by Chef for all Resources for use with notifications and subscriptions.

netapp_e_storage_system
-----------
Management of storage pools.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the storage pool.

### Attributes ###
This resource has the following attributes:

* `storage_system` string. Required, name_attibute. IP address of the storage system.
* `password` string. The SYMbol password for the storage system.
* `wwn` string. The world wide name for the storage system. This is only needed for in-band management with an in-band agent that is managing more than a single storage system.
* `meta_tags` array of strings. Optional meta tags to associate to this storage system

### Example ###

````ruby
netapp_e_storage_system '192.168.1.1' do
  password 'Netapp123'

  action :create
end
````

````ruby
netapp_e_storage_system '192.168.1.1' do
  action :delete
end
````


netapp_e_disk_pool
-----------
Management of disk storage pools.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the storage pool.

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attibute. The user-label to assign to the new disk storage pool.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `disk_drive_ids` array of strings. The identifiers of the disk drives to use for creating the storage pool. Required for disk_pool creation.

### Example ###

````ruby
netapp_e_disk_pool 'my_disk_pool' do
  storage_system '192.168.1.1'
  disk_drive_ids %w(010000005000C5004B993D9B0000000000000000 010000005000CCA016B152540000000000000000)
  action :create
end
````

````ruby
netapp_e_disk_pool 'my_disk_pool' do
  storage_system '192.168.1.1'
  action :delete
end
````

netapp_e_volume_group
-----------
Management of volume groups.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the volume.

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attibute. The user-label to assign to the new storage pool.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `disk_drive_ids` array of strings. The identifiers of the disk drives to use for creating the storage pool.  Required for disk_pool creation.
* `raid_level` string. The RAID configuration for the new storage pool. Possible values: 'Unsupported', 'All', '0', '1', '3', '5', '6' or 'DiskPool'. Required for volume_group creation.

### Example ###

````ruby
netapp_e_volume_group 'my_volume_group' do
  storage_system '192.168.1.1'
  disk_drive_ids %w(010000005000C5004B993D9B0000000000000000 010000005000CCA016B152540000000000000000)
  raid_level '0'
  action :create
end
````

````ruby
netapp_e_volume_group 'my_volume_group' do
  storage_system '192.168.1.1'
  action :delete
end
````

netapp_e_volume
-----------
Management of volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the volume.

### Attributes ###
This resource has the following attributes:

* `volume_name` string. Required, name_attibute. The user-label to assign to the new volume.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `pool_id` string. The identifier of the storage pool from which the volume will be allocated. Required for volume creation.
* `size_unit` string. Unit for "size". Possible values: 'bytes', 'b', 'kb', 'mb', 'gb', 'tb', 'pb, 'eb', 'zb', 'yb' . Required for volume creation.
* `size` integer. Number of units (See sizeUnit) to make the volume. Required for volume creation.
* `segment_size` integer. The segment size of the volume. Required for volume creation.

### Example ###

````ruby
netapp_e_volume 'my_volume' do
  storage_system '192.168.1.1'
  pool_id '0400000060080E50003220A80000006F52D8010D'
  size_unit 'gb'
  size 100
  segment_size 0

  action :create
end
````

````ruby
netapp_e_volume 'my_volume' do
  storage_system '192.168.1.1'

  action :delete
end
````

netapp_e_thin_volume
-----------
Management of thin volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the thin volume.

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attibute. The user-label to assign to the new thin volume.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `pool_id` string. The identifier of the storage pool from which the volume will be allocated. Required for thin volume creation.
* `size_unit` string. Unit for "size". Possible values: 'bytes', 'b', 'kb', 'mb', 'gb', 'tb', 'pb, 'eb', 'zb', 'yb' . Required for thin volume creation.
* `virtual_size` integer. Initial virtual capacity of the volume in units (See sizeUnit). Required for thin volume creation.
* `repository_size` integer. Number of units (See sizeUnit) to make the repository volume, which is the backing for the thin volume.
* `max_repository_size` integer. Maximum size (in sizeUnits) to which the thin volume repository can grow. Required for thin volume creation.
* `owning_controller` String. Set the initial owning controller
* `growth_alert_threshold` integer. The repository utilization warning threshold (in percent). This parameter is only required for thin-provisioned volumes. Default: 95.
* `create_default_mapping` boolean. Create the default volume mapping. Defaults to false.
* `expansion_policy` string. Thin Volume expansion policy. If automatic, the thin volume will be expanded automatically when capacity is exceeded, if manual, the volume must be expanded manually. Defaults to automatic. Possible values: 'unknown', 'manual', 'automatic'.
* `cache_read_ahead` boolean. Enable/Disable automatic cache read-ahead.

### Example ###

````ruby
netapp_e_thin_volume 'my_thin_volume' do
  storage_system '192.168.1.1'
  pool_id '0400000060080E50003222300000025853F33C1A'
  size_unit 'gb'
  virtual_size 4
  repository_size 4
  max_repository_size 128

  action :create
end
````

````ruby
netapp_e_thin_volume 'my_thin_volume' do
  storage_system '192.168.1.1'

  action :delete
end
````

netapp_e_snapshot_group
-----------
Management of snapshot groups

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the snapshot group

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attibute. The user-label to assign to the new group snapshot.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `base_mappable_object_id` string. The identifier of the volume, thin volume, or PIT View for the new snapshot group. Required for group snapshot creation.
* `repository_percentage` integer. The size of the repository in relation to the size of the base volume. Required for group snapshot creation.
* `warning_threshold` integer. The repository utilization warning threshold, as a percentage of the repository volume capacity. Required for group snapshot creation.
* `auto_delete_limit` integer. The automatic deletion indicator. If non-zero, the oldest snapshot image will be automatically deleted when creating a new snapshot image to keep the total number of snapshot images limited to the number specified. This value is overridden by the consistency group setting if this snapshot group is associated with a consistency group.. Require for group snapshot creation.
* `full_policy` string. The behavior on when the data repository becomes full. This value is overridden by consistency group setting if this snapshot group is associated with a consistency group. Possible values: 'unknown', 'failbasewrites', 'purgepit'. Required for group snapshot creation.
* `storage_pool_id` string. The identifier of the storage pool to allocate the repository volume. Required for group snapshot creation.

### Example ###

````ruby
netapp_e_snapshot_group 'my_snapshot_group' do
  storage_system '192.168.1.1'
  base_mappable_object_id '0200000060080E500032223000000388543E09C1'
  repository_percentage 100
  warning_threshold 0
  auto_delete_limit 32
  full_policy 'failbasewrites'
  storage_pool_id '0400000060080E50003220A80000006F52D8010D'

  action :create
end
````

````ruby
netapp_e_snapshot_group 'my_snapshot_group' do
  storage_system '192.168.1.1'

  action :delete
end
````

netapp_e_snapshot_volume
-----------
Management of snapshot volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the snapshot volume

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attibute. The name of the new snapshot volume.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `snapshot_image_id` string. The identifier of the snapshot image used to create the new snapshot volume. Required for volume snapshot creation.
* `full_threshold` Integer. The repository utilization warning threshold percentage. Required for volume snapshot creation.
* `view_mode` string. The snapshot volume access mode. Possible values: 'modeUnknown', 'readWrite', 'readOnly'.Required for volume snapshot creation.
* `repository_percentage` integer. The size of the view in relation to the size of the base volume. Required for volume snapshot creation.
* `repository_pool_id` string. The identifier of the storage pool to allocate the repository volume. Required for volume snapshot creation.

### Example ###

````ruby
netapp_e_snapshot_volume 'my_snapshot_volume' do
  storage_system '192.168.1.1'
  snapshot_image_id '3400000060080E5000322230006303BB543F6228'
  full_threshold 0
  view_mode 'readWrite'
  repository_percentage 100
  repository_pool_id '0400000060080E50003222300000025853F33C1A'

  action :create
end
````

````ruby
netapp_e_snapshot_volume 'my_snapshot_volume' do
  storage_system '192.168.1.1'

  action :delete
end
````

netapp_e_host
-----------
Management of hosts

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the host

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attibute. The user-label to assign to the new host.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `group_id` string. Host group id.
* `ports` array. A list of host ports.
* `host_default` boolean. Indicates if the host port type is the one used by default. Required for host creation.
* `code` String. The host-type abbreviation code stored in the storage system. Required for host creation.
* `host_used` boolean. Set to "true" when the host type is set valid. Required for host creation.
* `index` integer. The host-type index number stored in the storage system.Required for host creation.
* `host_type_name` string. The host-type name (decoded from the abbreviation).Required for host creation.

### Example ###

````ruby
netapp_e_host 'my_host' do
  storage_system '192.168.1.1'
  host_default false
  code 'demo_code'
  host_used true
  index 0
  host_type_name 'dc'

  action :create
end
````

````ruby
netapp_e_host 'my_host' do
  storage_system '192.168.1.1'

  action :delete
end
````

netapp_e_host_group
-----------
Management of host groups

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the host group

attribute :name, kind_of: String, required: true, name_attribute: true
attribute :storage_system, kind_of: String, required: true

attribute :hosts, kind_of: Array

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attibute. The user-label to assign to the new host group.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `hosts` string. List of hostRefs to assign to the HostGroup.

### Example ###

````ruby
netapp_e_host_group 'my_host_group' do
  storage_system '192.168.1.1'

  action :create
end
````

````ruby
netapp_e_host_group 'my_host_group' do
  storage_system '192.168.1.1'

  action :delete
end


netapp_e_iscsi
-----------
Configures ISCSI target aliases.

### Actions ###
This resource has the following actions:

* `:update` Default.

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.
* `iscsi_alias` string. Required. The iSCSI target alias.
* `enable_chap_authentication` boolean. Enable Challenge-Handshake Authentication Protocol (CHAP), defaults to false.
* `chap_secret` string. Enable Challenge-Handshake Authentication Protocol (CHAP) using the provided password. A secure password will be generated and returned if CHAP is enabled and this field is not provided.

### Example ###

````ruby
netapp_e_iscsi '192.168.1.1' do
  iscsi_alias 'my_alias'
  enable_chap_authentication false

  action :update
end
````


netapp_e_password
-----------
Set the password of the storage system.

### Actions ###
This resource has the following actions:

* `:update` Default.

### Attributes ###
This resource has the following attributes:

* `storage_system` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.
* `current_admin_password` string. Required. The current admin password
* `admin_password` boolean. Required. If this is true, this call will set the admin password, if false, it sets the RO password
* `new_password` string. Required. The new password

### Example ###

````ruby
netapp_e_password '192.168.1.1' do
  current_admin_password ''
  admin_password true
  new_password 'netapp123'

  action :update
end
````


Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Authors:: Matt Ray (matt@getchef.com)

```text
Copyright 2014 Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
