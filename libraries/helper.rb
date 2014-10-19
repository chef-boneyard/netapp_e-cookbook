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
  rescue
    Chef::Log.error('One or more mandatory parameters are not provided or are set incorrectly')
    exit
  end

  def netapp_api_create
    # Validate the mandatory parameters and create a netapp api object
    validate_node_attributes

    begin
      # Check if user has given a timeout value
      timeout_set = true if node['netapp']['api']['timeout']
    rescue
      timeout_set = false
    end

    if timeout_set
      NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'], node['netapp']['api']['timeout']) if node['netapp']['api']['timeout']
    else
      NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'])
    end
  end
end
