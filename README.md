[![Build Status](https://travis-ci.org/chef-partners/netapp_e-cookbook.png)](https://travis-ci.org/chef-partners/netapp_e-cookbook)

NetApp E-Series Cookbook
========================

The NetApp E-Series cookbook manages E-Series storage arrays using the NetApp SANtricity Web Services Proxy.
https://library.netapp.com/ecm/ecm_download_file/ECMP1394573

Requirements
------------
#### NetApp SANtricity Web Services Proxy

You may download it from [NetApp](http://mysupport.netapp.com/NOW/download/software/eseries_webservices/1.0/) after you have created an account on [NetApp NOW](https://support.netapp.com/eservice/public/now.do). You may install it manually or use the `proxy` recipe.

You need to rename the directory to netapp_e from netapp_e-cookbook in order to use the resources.

#### NetApp SANtricity Web Service Proxy Upgrade

Use `auto_upgrade` recipe to upgrade your NetApp SANtricity Web Service Proxy

NetApp E-Series connection
-----------------
In order to use the Resources provided by the cookbook you need to include the `default` recipe in your run-list. The connection is made over HTTPS through the SANtricity Web Services Proxy and the connection settings are managed by attributes.

    ['netapp']['https'] boolean
    ['netapp']['user'] string
    ['netapp']['password'] string
    ['netapp']['fqdn'] string
    ['netapp']['basic_auth'] boolean
    ['netapp']['asup'] boolean

The ASUP option, if set to 'true', will cause a log message to be sent to the proxy. This log message will be included in ASUP bundles that are sent back to NetApp, if configured to do so on the proxy application. If ASUP is not enabled on the proxy or on the attribute listed above, no log message will be sent to NetApp.

You can optionally provide the web proxy port and http timeout by providing the attributes port and timeout respectively.

    ['netapp']['port'] string
    ['netapp']['timeout'] integer

You need to have the necessary certificates in the environment path of machine if you are using https for the connection with the web proxy.

NetApp E-Series Recipes
=======================

default
-------
This recipe is required for using the cookbook's Resources, it installs the required `excon` gem for the Chef client.

proxy
-----
This recipe will install the SANtricity proxy service on Red Hat Linux 6 & 7, Windows Server 2012 R2 currently. It is unavailable for direct download from NetApp's website so you will need to mirror it locally and provide this URL as an attribute.

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

* `storage_system` string. Required, name_attribute. IP address of the storage system.
* `password` string. The SYMbol password for the storage system.
* `wwn` string. The world wide name for the storage system. This is only needed for in-band management with an in-band agent that is managing more than a single storage system.
* `meta_tags` array of strings. Optional meta tags to associate to this storage system

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['storage_system']['password'] = 'Netapp123'
```
Recipe

```ruby
netapp_e_storage_system node['netapp']['storage_system_ip'] do
  password node['netapp']['storage_system']['password']
  action :create
end
```

```ruby
netapp_e_storage_system node['netapp']['storage_system_ip'] do
  action :delete
end
```


netapp_e_disk_pool
-----------
Management of disk storage pools.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the storage pool.

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The user-label to assign to the new disk storage pool.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `disk_drive_ids` array of strings. The identifiers of the disk drives to use for creating the storage pool. Required for disk_pool creation.
* `raid_level` String, Required. The RAID configuration for the new storage pool. = ['raidUnsupported', 'raidAll', 'raid0', 'raid1', 'raid3', 'raid5', 'raid6', 'raidDiskPool', '__UNDEFINED'],

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['disk_pool']['name'] = 'demo_disk_pool'
default['netapp']['disk_pool']['raid_level'] = 'raidDiskPool'
default['netapp']['disk_pool']['disk_drive_ids'] = %w(010000005000C5004B993D9B0000000000000000 010000005000CCA016B152540000000000000000)
```
Recipe

```ruby
netapp_e_disk_pool node['netapp']['disk_pool']['name'] do
  storage_system node['netapp']['storage_system_ip']
  disk_drive_ids node['netapp']['disk_pool']['disk_drive_ids']
  raid_level node['netapp']['disk_pool']['raid_level']

  action :create
end
```

```ruby
netapp_e_disk_pool node['netapp']['disk_pool']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```

netapp_e_volume_group
-----------
Management of volume groups.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the volume.

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The user-label to assign to the new storage pool.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `disk_drive_ids` array of strings. The identifiers of the disk drives to use for creating the storage pool.  Required for disk_pool creation.
* `raid_level` string. The RAID configuration for the new storage pool. Possible values: 'Unsupported', 'All', '0', '1', '3', '5', '6' or 'DiskPool'. Required for volume_group creation.

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['volume_group']['name'] = 'volume_group_test'
default['netapp']['volume_group']['disk_drive_id'] = ['010000005001E8200002D1880000000000000000']
default['netapp']['volume_group']['raid_level'] = '0'
```
Recipe

```ruby
netapp_e_volume_group node['netapp']['volume_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  raid_level node['netapp']['volume_group']['raid_level']
  disk_drive_ids node['netapp']['volume_group']['disk_drive_id']

  action :create
end
```

```ruby
netapp_e_volume_group node['netapp']['volume_group']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```

netapp_e_volume
-----------
Management of volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the volume.

### Attributes ###
This resource has the following attributes:

* `volume_name` string. Required, name_attribute. The user-label to assign to the new volume.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `pool_id` string. The identifier of the storage pool from which the volume will be allocated. Required for volume creation.
* `size_unit` string. Unit for "size". Possible values: 'bytes', 'b', 'kb', 'mb', 'gb', 'tb', 'pb, 'eb', 'zb', 'yb' . Required for volume creation.
* `size` integer. Number of units (See sizeUnit) to make the volume. Required for volume creation.
* `segment_size` integer. The segment size of the volume. Required for volume creation.

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['volume']['name'] = 'my_volume'
default['netapp']['volume']['pool_id'] = '040d0001F69B400000C9E565D3F33'
default['netapp']['volume']['size_unit'] = 'bytes'
default['netapp']['volume']['size'] = 1048576
default['netapp']['volume']['segment_size'] = 128
```
Recipe

```ruby
netapp_e_volume node['netapp']['volume']['name'] do
  storage_system node['netapp']['storage_system_ip']
  pool_id node['netapp']['volume']['pool_id']
  size_unit node['netapp']['volume']['size_unit']
  size node['netapp']['volume']['size']
  segment_size node['netapp']['volume']['segment_size']

  action :create
end

netapp_e_volume node['netapp']['volume']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```

netapp_e_thin_volume
-----------
Management of thin volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the thin volume.

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The user-label to assign to the new thin volume.
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

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['thin_volume']['pool_id'] = '0400000060080E50003222300000025853F33C1A'
default['netapp']['thin_volume']['name'] = 'my_thin_volume'
default['netapp']['thin_volume']['size_unit'] = 'bytes'
default['netapp']['thin_volume']['virtual_size'] = 4
default['netapp']['thin_volume']['repository_size'] = 4
default['netapp']['thin_volume']['max_repository_size'] = 128
```
Recipe

```ruby
netapp_e_thin_volume node['netapp']['thin_volume']['name'] do
  storage_system node['netapp']['storage_system_ip']
  pool_id node['netapp']['thin_volume']['pool_id']
  size_unit node['netapp']['thin_volume']['size_unit']
  virtual_size node['netapp']['thin_volume']['virtual_size']
  repository_size node['netapp']['thin_volume']['repository_size']
  max_repository_size node['netapp']['thin_volume']['max_repository_size']

  action :create
end

netapp_e_thin_volume node['netapp']['thin_volume']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```


netapp_e_snapshot_group
-----------
Management of snapshot groups

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the snapshot group

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The user-label to assign to the new group snapshot.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `base_mappable_object_id` string. The identifier of the volume, thin volume, or PIT View for the new snapshot group. Required for group snapshot creation.
* `repository_percentage` integer. The size of the repository in relation to the size of the base volume. Required for group snapshot creation.
* `warning_threshold` integer. The repository utilization warning threshold, as a percentage of the repository volume capacity. Required for group snapshot creation.
* `auto_delete_limit` integer. The automatic deletion indicator. If non-zero, the oldest snapshot image will be automatically deleted when creating a new snapshot image to keep the total number of snapshot images limited to the number specified. This value is overridden by the consistency group setting if this snapshot group is associated with a consistency group.. Require for group snapshot creation.
* `full_policy` string. The behavior on when the data repository becomes full. This value is overridden by consistency group setting if this snapshot group is associated with a consistency group. Possible values: 'unknown', 'failbasewrites', 'purgepit'. Required for group snapshot creation.
* `storage_pool_id` string. The identifier of the storage pool to allocate the repository volume. Required for group snapshot creation.

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['snapshot_group']['name'] = 'demo_snapshot_group'
default['netapp']['snapshot_group']['base_mappable_object_id'] = '0200000060080E50001F69B40000151856611C78'
default['netapp']['snapshot_group']['repository_percentage'] = 20
default['netapp']['snapshot_group']['warning_threshold'] = 80
default['netapp']['snapshot_group']['auto_delete_limit'] = 30
default['netapp']['snapshot_group']['full_policy'] = 'unknown'
default['netapp']['snapshot_group']['storage_pool_id'] = '0400000060080E50001F69B4000015175660AFB0'
```
Recipe

```ruby
netapp_e_snapshot_group node['netapp']['snapshot_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  base_mappable_object_id node['netapp']['snapshot_group']['base_mappable_object_id']
  repository_percentage node['netapp']['snapshot_group']['repository_percentage']
  warning_threshold node['netapp']['snapshot_group']['warning_threshold']
  auto_delete_limit node['netapp']['snapshot_group']['auto_delete_limit']
  full_policy node['netapp']['snapshot_group']['full_policy']
  storage_pool_id node['netapp']['snapshot_group']['storage_pool_id']

  action :create
end

netapp_e_snapshot_group node['netapp']['snapshot_group']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```

netapp_e_snapshot_volume
-----------
Management of snapshot volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the snapshot volume

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The name of the new snapshot volume.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `snapshot_image_id` string. The identifier of the snapshot image used to create the new snapshot volume. Required for volume snapshot creation.
* `full_threshold` Integer. The repository utilization warning threshold percentage. Required for volume snapshot creation.
* `view_mode` string. The snapshot volume access mode. Possible values: 'modeUnknown', 'readWrite', 'readOnly'.Required for volume snapshot creation.
* `repository_percentage` integer. The size of the view in relation to the size of the base volume. Required for volume snapshot creation.
* `repository_pool_id` string. The identifier of the storage pool to allocate the repository volume. Required for volume snapshot creation.

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['snapshot_volume']['name'] = 'demo_snapshot_volume'
default['netapp']['snapshot_volume']['snapshot_image_id'] = '3400000060080E5000322230006303BB543F6228'
default['netapp']['snapshot_volume']['full_threshold'] = 0
default['netapp']['snapshot_volume']['view_mode'] = 'readWrite'
default['netapp']['snapshot_volume']['repository_percentage'] = 10_000_000_000
default['netapp']['snapshot_volume']['repository_pool_id'] = '0400000060080E50003222300000025853F33C1A'
```
Recipe

```ruby
netapp_e_snapshot_volume node['netapp']['snapshot_volume']['name'] do
  storage_system node['netapp']['storage_system_ip']
  snapshot_image_id node['netapp']['snapshot_volume']['snapshot_image_id']
  full_threshold node['netapp']['snapshot_volume']['full_threshold']
  view_mode node['netapp']['snapshot_volume']['view_mode']
  repository_percentage node['netapp']['snapshot_volume']['repository_percentage']
  repository_pool_id node['netapp']['snapshot_volume']['repository_pool_id']

  action :create
end

netapp_e_snapshot_volume node['netapp']['snapshot_volume']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```

netapp_e_host
-----------
Management of hosts

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the host

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The user-label to assign to the new host.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `group_id` string. Host group id.
* `ports` array. A list of host ports.
* `host_default` boolean. Indicates if the host port type is the one used by default. Required for host creation.
* `code` String. The host-type abbreviation code stored in the storage system. Required for host creation.
* `host_used` boolean. Set to "true" when the host type is set valid. Required for host creation.
* `index` integer. The host-type index number stored in the storage system.Required for host creation.
* `host_type_name` string. The host-type name (decoded from the abbreviation).Required for host creation.

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['host']['name'] = 'Demo_Host_1'
default['netapp']['host']['host_default'] = false
default['netapp']['host']['code'] = 'VmwTPPGFLUA'
default['netapp']['host']['host_used'] = true
default['netapp']['host']['index'] = 0
default['netapp']['host']['host_type_name'] = 'VmwTPPGFLUA'
default['netapp']['host']['ports'] = [{ 'type' => 'fc', 'port' => '4983294832', 'label' => 'esx_140a' }]
default['netapp']['host']['groupid'] = '8500000060080E50001F69B400360CBE565E35E3'
```
Recipe

```ruby
netapp_e_host node['netapp']['host']['name'] do
  storage_system node['netapp']['storage_system_ip']
  host_default node['netapp']['host']['host_default']
  code node['netapp']['host']['code']
  host_used node['netapp']['host']['host_used']
  index node['netapp']['host']['index']
  host_type_name node['netapp']['host']['host_type_name']
  ports node['netapp']['host']['ports']
  group_id node['netapp']['host']['groupid']

  action :create
end

netapp_e_host node['netapp']['host']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```

netapp_e_host_group
-----------
Management of host groups

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the host group

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The user-label to assign to the new host group.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.
* `hosts` string. List of hostRefs to assign to the HostGroup.

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['host_group']['name'] = 'testy_host_group'
```
Recipe

```ruby
netapp_e_host_group node['netapp']['host_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  hosts node['netapp']['host_group']['hosts']
  action :create
end

netapp_e_host_group node['netapp']['host_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  action :delete
end
```

netapp_e_iscsi
-----------
Configures ISCSI target aliases.

### Actions ###
This resource has the following actions:

* `:update` Default.

### Attributes ###
This resource has the following attributes:

* `storage_system` IP address string, Required, name attribute. IP address of the storage system being managed by the proxy.
* `iscsi_alias` string. Required. The iSCSI target alias.
* `enable_chap_authentication` boolean. Enable Challenge-Handshake Authentication Protocol (CHAP), defaults to false.
* `chap_secret` string. Enable Challenge-Handshake Authentication Protocol (CHAP) using the provided password. A secure password will be generated and returned if CHAP is enabled and this field is not provided.

### Example ###

Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['iscsi']['alias_name'] = 'demo_alias'
default['netapp']['iscsi']['enable_chap_authentication'] = false
```

Recipe

```ruby
netapp_e_iscsi node['netapp']['storage_system_ip'] do
  iscsi_alias node['netapp']['iscsi']['alias_name']
  enable_chap_authentication node['netapp']['iscsi']['enable_chap_authentication']

  action :update
end
```


netapp_e_password
-----------
Set the password of the storage system.

### Actions ###
This resource has the following actions:

* `:update` Default.

### Attributes ###
This resource has the following attributes:

* `storage_system` IP address string, Required, name attribute. IP address of the storage system being managed by the proxy.
* `current_admin_password` string. Required. The current admin password
* `admin_password` boolean. Required. If this is true, this call will set the admin password, if false, it sets the RO password
* `new_password` string. Required. The new password

### Example ###

```ruby
netapp_e_password '192.168.1.1' do
  current_admin_password ''
  admin_password true
  new_password 'netapp123'

  action :update
end
```


netapp_e_consistency_group
-----------

Management of consistency group

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the consistency group.

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The user-label to assign to the new consistency group.
* `storage_system` IP address string. Required. IP address of the storage system being managed by the proxy.

### Example ###
Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['consistency_group']['name'] = 'my_consistency_group'
```

Recipe

```ruby
netapp_e_consistency_group node['netapp']['consistency_group']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :create
end
```

```ruby
netapp_e_consistency_group node['netapp']['consistency_group']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```


netapp_e_mirror_group
-----------

Management of mirror group

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the mirror group.

### Attributes ###
This resource has the following attributes:

* `name` string. Required, name_attribute. The user-label to assign to the new new async mirror group.
* `storage_system` Required, IP address string. IP address of the storage system being managed by the proxy.
* `secondary_array_id` Required, Id string. The id of the secondary array.
* `sync_interval_minutes` integer. Sync interval in (minutes).
* `manual_sync` boolean. Set the synchronization method to manual, causing other synchronization values to be ignored.
*  `recovery_warn_threshold_minutes` integer. Recovery point warning threshold (minutes). The user will be warned when the age of the last good failures point exceeds this value.
* `report_utilization_warn_threshold` integer. Recovery point warning threshold (minutes).
* `interface_type` string. The intended protocol to use if both Fibre and iSCSI are available. = ['[fibre', 'iscsi]']
* `sync_warn_threshold_minutes` integer. The threshold (in minutes) for notifying the user that periodic synchronization has taken too long to complete.

### Example ###
Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['mirror_group']['name'] = 'mirror_group'
default['netapp']['mirror_group']['secondary_array_id'] = '3400000060080E5000322230006303BB543F6228'
```

Recipe

```ruby
netapp_e_mirror_group node['netapp']['mirror_group']['name']  do
  storage_system node['netapp']['storage_system_ip']
  secondary_array_id node['netapp']['mirror_group']['secondary_array_id']

  action :create
end
```

```ruby
netapp_e_mirror_group node['netapp']['mirror_group']['name'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```


netapp_e_volume_copies
-----------

Management of volume copies

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the mirror group.

### Attributes ###
This resource has the following attributes:

* `storage_system` IP address string, Required, name attribute. IP address of the storage system being managed by the proxy.
* `source_id` ID string. Required, The identifier of the source volume for the copy job.
* `target_id` ID string. Required, The identifier of the target volume for the copy job.
* `vc_id` Volume copy ID string, Required for deletion of volume copy.

### Example ###
Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['volume_copy']['name'] = 'my_volume_copy'
default['netapp']['volume_copy']['vc_id'] = '1800000060080E50001F6D3800000BAB565CF495'
default['netapp']['volume_copy']['source_id'] = '0200000060080E50001F6D3800000BA7565CDA7A'
default['netapp']['volume_copy']['target_id'] = '0200000060080E50001F69B400000C85565CD969'
```

Recipe

```ruby
netapp_e_volume_copy node['netapp']['volume_copy']['name'] do
  storage_system node['netapp']['storage_system_ip']
  source_id node['netapp']['volume_copy']['source_id']
  target_id node['netapp']['volume_copy']['target_id']

  action :create
end
```

```ruby
netapp_e_volume_copy node['netapp']['volume_copy']['vc_id'] do
  storage_system node['netapp']['storage_system_ip']

  action :delete
end
```


netapp_e_ssd_cache
-----------

Management of ssd/flash cache

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the ssd/flash cache.
* `:update` Add drives to an existing flash/ssd cache
* `:resume` Resume suspended flash/ssd cache
* `:suspend` Suspend the flash/ssd cache


### Attributes ###
This resource has the following attributes:

* `storage_system` IP address string, Required, name attribute. IP address of the storage system being managed by the proxy.
* `drive_refs` ID string. Required, A list of one or more drive refs belonging to SSD drives that will be utilized in the Flash/SSD Cache,
* `name` string, The user label for the Flash/SSD Cache.
* `enable_existing_volumes` If true, all existing volumes that are mapped will have FLASH/SSD cache enabled.

### Example ###
Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['ssd_cache']['drive_refs'] = %w(123, 234)
default['netapp']['ssd_cache']['name'] = 'flashCache'
default['netapp']['ssd_cache']['enable_existing_volumes'] = false
```
Recipe

```ruby
netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  drive_refs node['netapp']['ssd_cache']['drive_refs']
  action :create
end
```

```ruby
netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  drive_refs node['netapp']['ssd_cache']['drive_refs']
  action :update
end
```

```ruby
netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  action :suspend
end
```

```ruby
netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  action :resume
end
```

```ruby
netapp_e_ssd_cache node['netapp']['storage_system_ip'] do
  action :delete
end
```

netapp_e_firmware
-----------

Initiate a Controller Firmware upgrade option

### Actions ###
This resource has the following actions:

* `:upgrade` Default.


### Attributes ###
This resource has the following attributes:

* `storage_system` IP address string, Required, name attribute. IP address of the storage system being managed by the proxy.
* 'cfw_file' string
* 'nvsram_file' string
* 'stage_firmware' false
* 'skip_mel_check' false Skip check of the MEL events for issues with the storage-system.

### Example ###
Set default attributes in attributes/default.rb

```ruby
default['netapp']['storage_system_ip'] = '192.168.1.1'
default['netapp']['firmware']['cfw_file'] = '<path_to_the_file>'
default['netapp']['firmware']['nvsram_file'] = '<path_to_the_file>'
default['netapp']['firmware']['stage_firmware'] = false
default['netapp']['firmware']['skip_mel_check'] = false
```
Recipe

```ruby
netapp_e_firmware node['netapp']['storage_system_ip'] do
  cfw_file node['netapp']['firmware']['cfw_file']
  nvsram_file node['netapp']['firmware']['nvsram_file']
  stage_firmware node['netapp']['firmware']['stage_firmware']
  skip_mel_check node['netapp']['firmware']['skip_mel_check']

  action :upgrade
end
```


netapp_e_network_configuration
-----------

Update the ethernet management connection configuration. This operation can lead to an inaccessible controller if performed incorrectly or if incorrect ip addresses, gateway addresses, etc. are provided. Configuration is performed by connecting to the alternate controller, so it must be accessible for the operation to succeed.

### Actions ###
This resource has the following actions:

* `:update` Default.


### Attributes ###
This resource has the following attributes:

* `controller_ref` string, Required
* `interface_ref`  string, Required. Reference to the Ethernet interface to configure.
* `update_parameters` hash, All optional parameters can be passed in this.

### Example ###
Set default attributes in attributes/default.rb

```ruby
default['netapp']['network_configuration']['controller_ref'] = '0700123343435345435535325555'
default['netapp']['network_configuration']['interface_ref'] = '280007003123124354345345354353452000000000000'
default['netapp']['network_configuration']['update_parameters'] = { 'enableRemoteAccess' => false, 'ipv4GatewayAddress' => '', 'ipv6GatewayAddress' => '', 'ipv4Address' => '', 'ipv6LocalAddress' => '', 'ipv4Enabled' = false, 'ipv4AddressConfigMethod' => 'configDhcp', 'ipv6Enabled' => false, 'ipv6AddressConfigMethod' => 'configStatic' }
```
Recipe

```ruby
netapp_e_network_configuration 'network_configuration_update' do
  storage_system node['netapp']['storage_system_ip']
  controller_ref node['netapp']['network_configuration']['controller_ref']
  interface_ref node['netapp']['network_configuration']['interface_ref']
  update_parameters node.default['netapp']['network_configuration']['update_parameters']

  action :update
end
```


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
Copyright 2015-2016 Chef Software, Inc.

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
