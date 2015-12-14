
netapp_e_mirror_group node['netapp']['mirror_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  secondary_array_id node['netapp']['mirror_group']['secondary_array_id']
  action :create
end

netapp_e_mirror_group node['netapp']['mirror_group']['name'] do
  storage_system node['netapp']['storage_system_ip']
  action :delete
end
