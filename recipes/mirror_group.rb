
netapp_e_mirror_group 'mirror_group' do

  storage_system '10.250.117.112'
  secondaryArrayId '1hkjshdkjh8hj' 
  syncIntervalMinutes 10

  action :create
end

netapp_e_mirror_group 'mirror_group' do
  storage_system '10.250.117.112'

  action :delete
end
