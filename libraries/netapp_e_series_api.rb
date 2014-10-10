require 'json'
require 'excon'

class NetApp
  class ESeries
    class Api
      # To do
      # Verify HTTP error codes and print appropriate error messages

      def initialize(url, storage_system_ip connect_timeout = nil)
        @url = url
        @storage_system_ip = storage_system_ip
        @connect_timeout = connect_timeout
      end

      def login(username, pwd)
        body = { userId: username, password: pwd }.to_json
        response = request(:post, '/devmgr/utils/login', body)
        fail "Login failed. HTTP error- #{response.status}" if response.status != 200
        @cookie = response.headers['Set-Cookie'].split(';').first
      end

      def logout(username, pwd)
        body = { userId: username, password: pwd }.to_json
        response = request(:delete, '/devmgr/utils/login', body)
        fail "Logout failed. HTTP error- #{response.status}" if response.status != 204
        @cookie = nil
      end

      def create_storage_system
        body = { controllerAddresses: @storage_system_ip }.to_json
        response = request(:post, '/devmgr/v2/storage-systems', body)
        if response.status != 200 && response.status != 201
          fail "Storage creation failed. HTTP error- #{response.status}"
        end
        response.status == 201 ? true :  false
      end

      def delete_storage_system
        system_id = get_storage_system_id
        # system id or wwn can be used to do storage related operations.
        if system_id.nil?
          false # the resource wasn't updated
        else
          response = request(:delete, "/devmgr/v2/storage-systems/#{system_id}")
          response.status == 200 ? true : (fail "Failed to remove storage system. HTTP etrror- #{response.status} while trying to delete storage system")
        end
      end

      def change_password(current_pwd, admin_pwd, new_pwd)
        body = { currentAdminPassword: current_pwd, adminPassword: admin_pwd, newPassword: new_pwd }
        system_id = get_storage_system_id
        if system_id.nil?
          false
        else
          response = request(:post, "/devmgr/v2/storage-systems/#{system_id}
           /passwords", body) unless system_id.nil?
          response.status == 201 ? true : (fail "Failed to change password. HTTP error- #{response.status} while trying to delete storage system")
        end
      end

      def create_storage_pool(raid_level, disk_drive_ids, name)
        system_id = get_storage_system_id
        if system_id.nil?
          false
        else
          body = { raidLevel: raid_level, diskDriveIds: disk_drive_ids, name: name }.to_json
          response = request(:post, "/devmgr/v2/storage-systems/#{system_id}/storage-pools", body)
          response.status == 200 ? true : (fail "Failed to create storage pool.HTTP error- #{response.status} while trying to delete storage system")
        end
      end

      def create_volume(poolid, name, size_unit, size, segment_size)
        system_id = get_storage_system_id
        if system_id.nil?
          false
        else
          body = { poolId: poolid, name: name, sizeUnit: size_unit, size: size, segSize: segment_size }.to_json
          response = request(:post, "/devmgr/v2/storage-systems/#{system_id}/volumes", body)
          response.status == 200 ? true : (fail "Failed to create volume. HTTP error- #{response.status} while trying to delete storage system")
        end
      end

      def update_volume(old_name, new_name)
        volume_id = get_volume_id(old_name)
        if volume_id.nil?
          false
        else
          body = { name: new_name }.to_json
          response = request(:post, "/devmgr/v2/storage-systems/#{system_id}/volumes/#{volume_id}", body)
          response.status == 200 ? true : (fail "Failed to create volume. HTTP error- #{response.status} while trying to delete storage system")
        end
      end

      def delete_volume(name)
        volume_id = get_volume_id(name)
        if volume_id.nil?
          false
        else
          response = request(:delete, "/devmgr/v2/storage-systems/#{system_id}/volumes/#{volume_id}")
          response.status == 200 ? true : (fail "Failed to create volume. HTTP error- #{response.status} while trying to delete storage system")
        end
      end

      private

      def get_storage_system_id
        response = request(:get, '/devmgr/v2/storage-systems')
        storage_systems = JSON.parse(response.body)
        storage_systems.each do |system|
          if system['ip1'] == @storage_system_ip || system['ip2'] == @storage_system_ip
            return system['id']
          end
        end
        nil
      end

      def get_volume_id(name)
        system_id = get_storage_system_id(@storage_system_ip)
        if system_id.nil?
          nil
        else
          response = request(:get, "/devmgr/v2/storage-systems/#{system_id}/volumes")
          volumes = JSON.parse(response.body)
          volumes.each do |volume|
            if volume['name'] == name
              return volume['id']
            end
          end
          nil
        end
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
