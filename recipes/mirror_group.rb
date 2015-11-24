
netapp_e_mirror_group 'mirror_group' do

  storage_system '10.113.1.130'
  secondaryArrayId 'e9f486b8-8634-4f58-9563-c57561633376'

  action :create
end

netapp_e_mirror_group 'mirror_group' do
  storage_system '10.113.1.130'

  action :delete
end
