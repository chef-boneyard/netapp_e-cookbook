# Mandatory Parameters

default['netapp']['https'] = false
default['netapp']['user'] = 'rw'
default['netapp']['password'] = 'rw'
default['netapp']['fqdn'] = 'localhost'
default['netapp']['basic_auth'] = true
default['netapp']['asup'] = true
default['netapp']['autoupdate'] = true

# Sample values
# For Linux
default['netapp']['installation_directory'] = '/opt/netapp/santricity_web_services_proxy'
default['netapp']['installer']['source_url'] = 'https://example.com/webservice-01.30.7000.0002.bin'

# For Windows
# default['netapp']['installation_directory'] = 'C://Program Files//NetApp//SANtricity Web Services Proxy'
# default['netapp']['installer']['source_url'] = 'https://example.com/webservice-01.30.3000.0003.exe'

default['netapp']['port'] = 8080
default['netapp']['ssl_port'] = 8443

############ timeout (optional) ######################
# default['netapp']['api']['timeout'] = 60000

default['netapp']['storage_system_ip'] = '127.0.0.1'

# storage system
default['netapp']['storage_system']['password'] = 'Netapp123' # optional parameter
# default['netapp']['storage_system']['wwn'] = '60080E50001F6D380000000056322C8A' # optional parameter
# default['netapp']['storage_system']['meta_tags'] = ['ABC111XYZ','Y999'] # optional parameter

# mirror group
default['netapp']['mirror_group']['name'] = 'mirror_group'
default['netapp']['mirror_group']['secondary_array_id'] = 'e9f486b8-8634-4f58-9563-c57561633376'

# Attributes for volume copy
default['netapp']['volume_copy']['vc_id'] = '1800000060080E50001F6D3800000BAB565CF495'  # required for delete operation
default['netapp']['volume_copy']['source_id'] = '0200000060080E50001F69B40000170A5666342B'
default['netapp']['volume_copy']['target_id'] = '0200000060080E50001F69B40000170B56663452'
# default['netapp']['volume_copy']['copy_priority'] = 'priority2'    # optional parameter, defaults to 'priority2'
# default['netapp']['volume_copy']['target_write_protected'] = false # optional parameter, defaults to false
# default['netapp']['volume_copy']['online_copy'] = false            # optional parameter, defaults to false

# ssd cache / flash cache
default['netapp']['ssd_cache']['drive_refs'] = %w(123, 234) # Need to pass drive refs its a array of string
default['netapp']['ssd_cache']['name'] = 'flashCache'              # optional parameter
default['netapp']['ssd_cache']['enable_existing_volumes'] = false  # optional parameter

# host group
default['netapp']['host_group']['name'] = 'testy_host_group'
# default['netapp']['host_group']['hosts'] = ['8400000060080E50001F6D3800300DFE565E8364','8400000060080E50001F69B400300EDE565E8283'] # optional parameter

# firmware upgrade
default['netapp']['firmware']['cfw_file'] = '<path_to_the_file>'
default['netapp']['firmware']['nvsram_file'] = '<path_to_the_file>'
default['netapp']['firmware']['stage_firmware'] = false
default['netapp']['firmware']['skip_mel_check'] = false

# volume group
default['netapp']['volume_group']['name'] = 'volume_group_test'
default['netapp']['volume_group']['disk_drive_id'] = ['010000005001E8200002D1880000000000000000']
default['netapp']['volume_group']['raid_level'] = '0'
# optional paramter for Volume Group
# default['netapp']['volume_group']['erase_secured_drives'] = false

# volume
default['netapp']['volume']['name'] = 'MyVolume'
default['netapp']['volume']['pool_id'] = '0400000060080E50001F69B400000C9E565D3F33'
default['netapp']['volume']['size_unit'] = 'bytes'
default['netapp']['volume']['size'] = 1048576
default['netapp']['volume']['segment_size'] = 128
# optional parameter for volume
# default['netapp']['volume']['data_assurance_enabled'] = false

# Host group
default['netapp']['host']['name'] = 'Demo_Host_1'
default['netapp']['host']['host_default'] = false
default['netapp']['host']['code'] = 'VmwTPPGFLUA'
default['netapp']['host']['host_used'] = true
default['netapp']['host']['index'] = 0
default['netapp']['host']['host_type_name'] = 'VmwTPPGFLUA'
default['netapp']['host']['ports'] = [{ 'type' => 'fc', 'port' => '4983294832', 'label' => 'esx_140a' },
                                      { 'type' => 'fc', 'port' => '2101001B32A2D180', 'label' => 'esx_140b' }
                                     ]
default['netapp']['host']['groupid'] = '8500000060080E50001F69B400360CBE565E35E3'

# iscsi updation
default['netapp']['iscsi']['alias_name'] = 'demo_alias'
default['netapp']['iscsi']['enable_chap_authentication'] = false

# thin Volumes
default['netapp']['thin_volume']['pool_id'] = '0400000060080E50003222300000025853F33C1A'
default['netapp']['thin_volume']['name'] = 'demo_thin_volume'
default['netapp']['thin_volume']['size_unit'] = 'bytes'
default['netapp']['thin_volume']['virtual_size'] = 4
default['netapp']['thin_volume']['repository_size'] = 4
default['netapp']['thin_volume']['max_repository_size'] = 128

# Snapshot Group
default['netapp']['snapshot_group']['name'] = 'demo_snapshot_group'
default['netapp']['snapshot_group']['base_mappable_object_id'] = '0200000060080E50001F69B40000151856611C78'
default['netapp']['snapshot_group']['repository_percentage'] = 20
default['netapp']['snapshot_group']['warning_threshold'] = 80
default['netapp']['snapshot_group']['auto_delete_limit'] = 30
default['netapp']['snapshot_group']['full_policy'] = 'unknown'
default['netapp']['snapshot_group']['storage_pool_id'] = '0400000060080E50003220A80000006F52D8010D'

# Snapshot Volume
default['netapp']['snapshot_volume']['name'] = 'demo_snapshot_volume'
default['netapp']['snapshot_volume']['snapshot_image_id'] = '3400000060080E5000322230006303BB543F6228'
default['netapp']['snapshot_volume']['full_threshold'] = 0
default['netapp']['snapshot_volume']['view_mode'] = 'readWrite'
default['netapp']['snapshot_volume']['repository_percentage'] = 10_000_000_000
default['netapp']['snapshot_volume']['repository_pool_id'] = '0400000060080E50003222300000025853F33C1A'
