module NetAppEHelper
  def url
    port = node['netapp']['port'] unless node['netapp']['port'].nil?

    if node['netapp']['https']
      "https://#{node['netapp']['fqdn']}:#{port.nil? ? 8443 :  port}"
    else
      "http://#{node['netapp']['fqdn']}:#{port.nil? ? 8080 :  port}"
    end
  end

  def netapp_api_create
    # Validate the mandatory parameters and create a netapp api object
    begin
      # Check if user has given a timeout value
      timeout_set = true if node['netapp']['api']['timeout']
    rescue
      timeout_set = false
    end

    begin
      fail unless node['netapp']['https'] == true || node['netapp']['https'] == false
      fail unless node['netapp']['user'].class == String
      fail unless node['netapp']['password'].class == String
      fail unless node['netapp']['fqdn'].class == String
      fail unless node['netapp']['basic_auth'] == true || node['netapp']['basic_auth'] == false

      if timeout_set
        NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'], node['netapp']['api']['timeout']) if node['netap']['api']['timeout']
      else
        NetApp::ESeries::Api.new(node['netapp']['user'], node['netapp']['password'], url, node['netapp']['basic_auth'])
      end
    rescue
      Chef::Log.error('One or more mandatory parameters are not provided or are set incorrectly')
      exit
    end
  end
end
