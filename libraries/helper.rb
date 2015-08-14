module NetAppEHelper
  def url
    if node['netapp']['https']
      "https://#{node['netapp']['fqdn']}:#{node['netapp']['port'].nil? ? 8443 :  node['netapp']['port']}"
    else
      "http://#{node['netapp']['fqdn']}:#{node['netapp']['port'].nil? ? 8080 :  node['netapp']['port']}"
    end
  end

  def validate_node_attributes
    fail unless node['netapp']['https'] == true || node['netapp']['https'] == false
    fail unless node['netapp']['user'].class == String
    fail unless node['netapp']['password'].class == String
    fail unless node['netapp']['fqdn'].class == String
    fail unless node['netapp']['basic_auth'] == true || node['netapp']['basic_auth'] == false
    fail unless node['netapp']['asup'] == true || node['netapp']['asup'] == false
  rescue
    Chef::Log.error('One or more mandatory parameters are not provided or are set incorrectly')
    exit
  end

  def netapp_api_create
    # Validate the mandatory parameters and create a netapp api object
    validate_node_attributes

    if node['netapp']['api']
      if node['netapp']['api']['timeout']
        return NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'], node['netapp']['asup'], node['netapp']['api']['timeout']) if node['netapp']['api']['timeout']
      end
    end
    NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'], node['netapp']['asup'])
  end
end
