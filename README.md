NetApp E-Series Cookbook
========================

The NetApp E-Series cookbook manages E-Series storage arrays using the NetApp SANtricity Web Services Proxy.
https://library.netapp.com/ecm/ecm_download_file/ECMP1394573

Requirements
------------
#### NetApp SANtricity Web Services Proxy

You may download it from [NetApp](http://mysupport.netapp.com/NOW/download/software/eseries_webservices/1.0/) after you have created an account on [NetApp NOW](https://support.netapp.com/eservice/public/now.do). You may install it manually or use the `proxy` recipe.

NetApp E-Series connection
-----------------
The connection is made over HTTPS through the SANtricity Web Services Proxy and the connection settings are managed by attributes.

    ['netapp']['proxyurl'] = 'https://root:secret@pfiler01.example.com/svm01'
or
    ['netapp']['https'] boolean, default is 'true'.
    ['netapp']['user'] string
    ['netapp']['password'] string
    ['netapp']['fqdn'] string
    ['netapp']['vserver'] string

NetApp E-Series Recipes
=======================

proxy
-----
This recipe will install the SANtricity proxy service on either Red Hat Linux 6 or Windows 2012 R2. It is unavailable for direct download from NetApp's website so you will need to mirror it locally and provide this URL as an attribute.

NetApp SANtricity Web Services Proxy 1.0	64-bit Windows	78 MB	webservice-01.00.3000.0003.exe
NetApp SANtricity Web Services Proxy 1.0	64-bit Linux	103 MB	webservice-01.00.7000.0003.bin

https://www.youtube.com/watch?v=MINP9nJ5r_g&list=UUoYBmy2WT8nQWn9WpOiwKWg

You may provide the IP addresses of the storage systems that are being managed.

    ['netapp']['storagesystems'] array of IP address strings

NetApp E-Series Resources
================

Common Attributes
-----------------
In addition to those provided by Chef itself (`ignore_failure`, `retries`, `retry_delay`, etc.), the connection attribute(s) are exposed all NetApp E-Series Resources even though they are typically set by attributes.

Common Actions
--------------
The `:nothing` action is provided by Chef for all Resources for use with notifications and subscriptions.

netapp_e_disk_pool
-----------
Management of disk storage pools.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the storage pool.

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.
* `label` string. Required. The user-label to assign to the new storage pool.
* `raidLevel` string. Required. Possible values: 'Unsupported', 'All', '0', '1', '3', '5', '6' or 'DiskPool'
* `diskDriveIds` array of strings.

### Example ###

````ruby
netapp_e_disk_pool '192.168.0.100' do
  label 'samplestorage'
  raidLevel 'raidDiskPool'
  action :create
end
````

````ruby
netapp_e_disk_pool '192.168.0.100' do
  label 'samplestorage'
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

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.
* `poolid` string. Required. The identifier of the storage pool from which the volume will be allocated.
* `name` string. Required. The user-label to assign to the new volume.
* `sizeUnit` string. Default is 'tb'. Possible values: 'bytes', 'b', 'kb', 'mb', 'gb', 'tb', 'pb', 'eb', 'zb', 'yb'
* `size` integer. Required. Number of units to make the volume.
* `segSize` integer. Required. The segment size of the volume.

### Example ###

netapp_e_volume
-----------
Management of volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the volume.

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.

### Example ###

netapp_e_thin_volume
-----------
Management of thin volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the thin volume.

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.

### Example ###

netapp_e_snapshot_volume
-----------
Management of snapshot volumes

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the snapshot volume

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.

### Example ###

netapp_e_snapshot_group
-----------
Management of snapshot groups

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the snapshot group

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.

### Example ###

netapp_e_host
-----------
Management of hosts

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the host

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.

### Example ###

netapp_e_host_group
-----------
Management of host groups

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the host group

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.

### Example ###

netapp_e_iscsi
-----------
Configures ISCSI target aliases.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the user

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.
* `alias` string. Required. The iSCSI target alias.
* `enableChapAuthentication` Boolean. Enable Challenge-Handshake Authentication Protocol (CHAP), defaults to false.
* `chapSecret` string. Enable Challenge-Handshake Authentication Protocol (CHAP) using the provided password. A secure password will be generated and returned if CHAP is enabled and this field is not provided.

### Example ###

netapp_e_password
-----------
Set the password of the storage system.

### Actions ###
This resource has the following actions:

* `:create` Default.

### Attributes ###
This resource has the following attributes:

* `storageSystem` IP address string, name attribute. Required. IP address of the storage system being managed by the proxy.
* `currentAdminPassword` string. Required. The current admin password
* `adminPassword` Boolean. Required. If this is true, this call will set the admin password, if false, it sets the RO password
* `newPassword` string. Required. The new password

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
