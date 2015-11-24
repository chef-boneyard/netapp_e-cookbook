
netapp_e_mirror_group node['netapp']['mirror_group']['name']  do

  storage_system node['netapp']['storage_system_ip']
  secondaryArrayId node['netapp']['mirror_group']['secondaryArrayId'] 
  action :create
end

netapp_e_mirror_group node['netapp']['mirror_group']['name'] do
  storage_system node['netapp']['storage_system_ip'] 

  action :delete
end

