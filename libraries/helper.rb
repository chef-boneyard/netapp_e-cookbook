module NetAppEHelper
  def url
    port = node['netapp']['port'] unless node['netapp']['port'].nil?

    if node['netapp']['https']
      "https://#{node['netapp']['fqdn']}:#{port.nil? ? 8443 :  port}"
    else
      "http://#{node['netapp']['fqdn']}:#{port.nil? ? 8080 :  port}"
    end
  end
end
