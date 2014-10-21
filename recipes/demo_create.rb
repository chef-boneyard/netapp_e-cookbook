netapp_e_storage_system '10.250.117.112' do
  password ''

  action :create
end

netapp_e_password '10.250.117.112' do
  current_admin_password ''
  admin_password true
  new_password 'Netapp123'

  action :update
end

netapp_e_disk_pool 'demo_disk_pool' do
  storage_system '10.250.117.112'
  disk_drive_ids %w(010000005000C5004B993D9B0000000000000000 010000005000CCA016B152540000000000000000 010000005000CCA016B19B600000000000000000 010000005000CCA016B2BCB00000000000000000 010000005000CCA016B2F5FC0000000000000000 010000005000CCA016B3B0980000000000000000 010000005000CCA0225C24B80000000000000000 010000005000CCA0225CD88C0000000000000000 010000005000CCA0225F50100000000000000000 010000005000CCA02260F2EC0000000000000000 010000005000CCA02260F3080000000000000000)

  action :create
end

netapp_e_volume_group 'demo_vol_group' do
  storage_system '10.250.117.112'
  raid_level '0'
  disk_drive_ids ['010000005000CCA016B3C9340000000000000000']

  action :create
end

netapp_e_host_group 'demo_host_group' do
  storage_system '10.250.117.112'

  action :create
end

netapp_e_host 'demo_host' do
  storage_system '10.250.117.112'
  host_default false
  code 'demo_code'
  host_used true
  index 0
  host_type_name 'dc'

  action :create
end

netapp_e_volume 'demo_vol' do
  storage_system '10.250.117.112'
  pool_id '0400000060080E50003220A80000006F52D8010D'
  size_unit 'b'
  size 100
  segment_size 0

  action :create
end

netapp_e_iscsi '10.250.117.112' do
  iscsi_alias 'demo_alias'
  enable_chap_authentication false

  action :update
end

netapp_e_snapshot_group 'demo_snapshot_group' do
  storage_system '10.250.117.112'
  base_mappable_object_id '0200000060080E500032223000000388543E09C1'
  repository_percentage 10_000_000_000
  warning_threshold 0
  auto_delete_limit 32
  full_policy 'failbasewrites'
  storage_pool_id '0400000060080E50003220A80000006F52D8010D'

  action :create
end

netapp_e_snapshot_volume 'demo_snapshot_volume' do
  storage_system '10.250.117.112'
  snapshot_image_id '3400000060080E5000322230006303BB543F6228'
  full_threshold 0
  view_mode 'readWrite'
  repository_percentage 10_000_000_000
  repository_pool_id '0400000060080E50003222300000025853F33C1A'

  action :create
end

netapp_e_thin_volume 'demo_thin_volume' do
  storage_system '10.250.117.112'
  pool_id '0400000060080E50003222300000025853F33C1A'
  size_unit 'gb'
  virtual_size 4
  repository_size 4
  max_repository_size 128

  action :create
end
