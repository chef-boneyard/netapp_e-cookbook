netapp_e_volume 'demo_vol' do
  storage_system '10.250.117.112'

  action :delete
end

netapp_e_volume_group 'demo_vol_group' do
  storage_system '10.250.117.112'

  action :delete
end

netapp_e_disk_pool 'demo_disk_pool' do
  storage_system '10.250.117.112'

  action :delete
end

netapp_e_host 'demo_host' do
  storage_system '10.250.117.112'

  action :delete
end

netapp_e_host_group 'demo_host_group' do
  storage_system '10.250.117.112'

  action :delete
end

netapp_e_password '10.250.117.112' do
  current_admin_password 'Netapp123'
  admin_password true
  new_password ''

  action :update
end

netapp_e_snapshot_volume 'demo_snapshot_volume' do
  storage_system '10.250.117.112'

  action :delete
end

netapp_e_snapshot_group 'demo_snapshot_group' do
  storage_system '10.250.117.112'

  action :delete
end

netapp_e_thin_volume 'demo_thin_volume' do
  storage_system '10.250.117.112'

  action :delete
end

netapp_e_storage_system '10.250.117.112' do
  action :delete
end
