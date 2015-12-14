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

# mirror group
default['netapp']['storage_system_ip'] = '10.113.1.18'
default['netapp']['mirror_group']['name'] = 'mirror_group'
default['netapp']['mirror_group']['secondary_array_id'] = 'e9f486b8-8634-4f58-9563-c57561633376'

# Attributes for volume copy
default['netapp']['volume_copy']['vc_id'] = '1800000060080E50001F6D3800000BAB565CF495'  # required for delete operation
default['netapp']['volume_copy']['source_id'] = '0200000060080E50001F69B40000170A5666342B'
default['netapp']['volume_copy']['target_id'] = '0200000060080E50001F69B40000170B56663452'
# default['netapp']['volume_copy']['copy_priority'] = 'priority2'    # optional parameter, defaults to 'priority2'
# default['netapp']['volume_copy']['target_write_protected'] = false # optional parameter, defaults to false
# default['netapp']['volume_copy']['online_copy'] = false            # optional parameter, defaults to false
