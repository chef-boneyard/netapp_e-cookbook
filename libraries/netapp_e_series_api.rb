require 'json'
require 'excon'

class NetApp
  class ESeries
    class Api
      def initialize(url, connect_timeout = nil)
        @url = url
        @connect_timeout = connect_timeout
      end

      def login(username, pwd)
        body = { userId: username, password: pwd }.to_json
        response = request(:post, '/devmgr/utils/login', body)
        fail "login failed. Http error- #{response.status}" if response.status != 200
        @cookie = response.headers['Set-Cookie'].split(';').first
      end

      def logout(username, pwd)
        body = { userId: username, password: pwd }.to_json
        response = request(:delete, '/devmgr/utils/login', body)
        fail "Logout failed. Http error- #{response.status}" if response.status != 204
        @cookie = nil
      end

      def add_storage_system(storage_system_ip)
        body = { controllerAddresses: storage_system_ip }.to_json
        response = request(:post, '/devmgr/v2/storage-systems', body)
        if response.status != 200 && response.status != 201
          fail "http error- #{response.status}"
        end
        response.status == 201 ? true :  false  # indicates if the resource was created or was already existing
      end

      def remove_storage_system(storage_system_ip)
        system_id = get_storage_system_id(storage_system_ip)
        # system id or wwn can be used to do storage related operations.
        if system_id.nil?
          false # the resource wasn't updated
        else
          response = request(:delete, "/devmgr/v2/storage-systems/#{system_id}")
          response.status == 200 ? true : (fail "http etrror- #{response.status} while trying to delete storage system")
        end
      end

      def change_password(storage_system_ip, current_pwd, admin_pwd, new_pwd)
        body = { currentAdminPassword: current_pwd, adminPassword: admin_pwd, newPassword: new_pwd }
        system_id = get_storage_system_id(storage_system_ip)
        if system_id.nil?
          false
        else
          response = request(:post, "/devmgr/v2/storage-systems/#{system_id}
           /passwords", body) unless system_id.nil?
          response.status == 201 ? true : (fail "http etrror- #{response.status} while trying to delete storage system")
        end
      end

      private

      def get_storage_system_id(storage_system_ip)
        response = request(:get, '/devmgr/v2/storage-systems')
        storage_systems = JSON.parse(response.body)
        storage_systems.each do |system|
          if system['ip1'] == storage_system_ip || system['ip2'] == storage_system_ip
            return system['id']
          end
        end
        nil
      end

      def request(method, path, body = nil)
        Excon.send(method, @url, path: path, headers: web_proxy_headers, body: body, connect_timeout: @connect_timeout)
      end

      def web_proxy_headers
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json', 'cookie' => @cookie }
      end
    end
  end
end
