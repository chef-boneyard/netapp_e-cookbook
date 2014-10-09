require 'json'
require 'excon'

module NetApp
  module Api
    def login(username, pwd)
      body = { userId: username, password: pwd }.to_json
      response = request(:post, url, '/devmgr/utils/login', body)
      fail "login failed. Http error- #{response.status}" if response.status != 200
      @cookie = response.headers['Set-Cookie'].split(';').first
    end

    def logout(username, pwd)
      body = { userId: username, password: pwd }.to_json
      response = request(:delete, url, '/devmgr/utils/login', body)
      fail "Logout failed. Http error- #{response.status}" if response.status != 204
      @cookie = nil
    end

    def add_storage_system(storage_system_ip)
      body = { controllerAddresses: storage_system_ip }.to_json
      response = request(:post, url, '/devmgr/v2/storage-systems', body)
      if response.status != 200 && response.status != 201
        fail "http error- #{response.status}"
      end
      response.status == 201 ? true :  false  # indicates if the resource was created or was already existing
    end

    def get_storage_system_id(storage_system_ip)
      response = request(:get, url, '/devmgr/v2/storage-systems')
      storage_systems = JSON.parse(response.body)
      storage_systems.each do |system|
        if system['ip1'] == storage_system_ip || system['ip2'] == storage_system_ip
          return system['id']
        end
      end
      nil
    end

    def remove_storage_system(storage_system_ip)
      system_id = get_storage_system_id(storage_system_ip)
      # system id or wwn can be used to do storage related operations.
      if system_id.nil?
        fail 'Storage system not found'
      else
        response = request(:delete, url, "/devmgr/v2/storage-systems/#{system_id}")
        response.status == 200 ? true :  false # or fail "http etrror- #{response.status} while trying to delete storage system"
      end
    end

    # This will remain with cookbook library and will not be exported to gem
    def url
      port = node['netapp']['port'] unless node['netapp']['port'].nil?

      if node['netapp']['https']
        "https://#{node['netapp']['fqdn']}:#{port.nil? ? 8443 :  port}"
      else
        "http://#{node['netapp']['fqdn']}:#{port.nil? ? 8080 :  port}"
      end
    end

    def request(method, url, path, body = nil, connection_timeout = nil)
      Excon.send(method, url, path: path, headers: web_proxy_headers, body: body, connect_timeout: connection_timeout)
    end

    def web_proxy_headers
      { 'Accept' => 'application/json', 'Content-Type' => 'application/json', 'cookie' => @cookie }
    end
  end
end
