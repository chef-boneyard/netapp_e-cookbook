require 'json'
require 'excon'

class NetApp
  class ESeries
    class Api
      # To do
      # Verify HTTP error codes and print appropriate error messages

      def initialize(user, password, url, basic_auth = true, connect_timeout = nil)
        @user = user
        @password = password
        @url = url
        @basic_auth = basic_auth
        @connect_timeout = connect_timeout
      end

      def create_storage_system(request_body)
        if @basic_auth
          response = request(:post, '/devmgr/v2/storage-systems', request_body.to_json)
          resource_update_status = status(response, '201', %w(201 200), 'Storage Creation Failed')
        else
          login
          response = request(:post, '/devmgr/v2/storage-systems', request_body.to_json)
          resource_update_status = status(response, '201', %w(201 200), 'Storage Creation Failed')
          logout
        end

        resource_update_status
      end

      def delete_storage_system(storage_system_ip)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          if @basic_auth
            response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}")
            resource_update_status = status(response, '201', %w(201 200), 'Storage Deletion Failed')
          else
            login
            response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}")
            resource_update_status = status(response, '201', %w(201 200), 'Storage Creation Failed')
            logout
          end

          resource_update_status
        end
      end

      def change_password(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          if @basic_auth
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/passwords", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Password Update Failed')
          else
            login
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/passwords", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Password Update Failed')
            logout
          end

          resource_update_status
        end
      end

      def create_host(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          if @basic_auth
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/hosts", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create host')
          else
            login
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/hosts", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create host')
            logout
          end

          resource_update_status
        end
      end

      def delete_host(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          host = host_id(sys_id, name)
          if hosthost.nil?
            false
          else
            if @basic_auth
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/hosts/#{host}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete host')
            else
              login
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/hosts/#{host}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete host')
              logout
            end

            resource_update_status
          end
        end
      end

      def create_host_group(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          if @basic_auth
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/host-groups", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create host group')
          else
            login
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/host-groups", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create host group')
            logout
          end

          resource_update_status
        end
      end

      def delete_host_group(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          host_grp_id = host_group_id(sys_id, name)
          if host_grp_id.nil?
            false
          else
            if @basic_auth
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/host-groups/#{host_grp_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete host group')
            else
              login
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/host-groups/#{host_grp_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete host group')
              logout
            end

            resource_update_status
          end
        end
      end

      def create_storage_pool(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          if @basic_auth
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/storage-pools", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create storage pool')
          else
            login
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/storage-pools", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create storage pool')
            logout
          end

          resource_update_status
        end
      end

      def delete_storage_pool(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          pool_id = storage_pool_id(sys_id, name)
          if pool_id.nil?
            false
          else
            if @basic_auth
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/storage-pools/#{pool_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete storage pool')
            else
              login
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/storage-pools/#{pool_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete storage pool')
              logout
            end

            resource_update_status
          end
        end
      end

      def create_volume(_storage_system_ip, request_body)
        sys_id = storage_system_id
        if sys_id.nil?
          false
        else
          if @basic_auth
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/volumes", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create volume')
          else
            login
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/volumes", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create volume')
            logout
          end

          resource_update_status
        end
      end

      def update_volume(storage_system_ip, old_name, new_name)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          vol_id = volume_id(sys_id, old_name)
          if vol_id.nil?
            false
          else
            body = { name: new_name }.to_json
            if @basic_auth
              response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/volumes/#{vol_id}", body)
              resource_update_status = status(response, '201', %w(201 200), 'Failed to update volume')
            else
              login
              response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/volumes/#{vol_id}", body)
              resource_update_status = status(response, '201', %w(201 200), 'Failed to update volume')
              logout
            end

            resource_update_status
          end
        end
      end

      def delete_volume(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          vol_id = volume_id(sys_id, name)
          if vol_id.nil?
            false
          else
            if @basic_auth
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/volumes/#{vol_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete volume')
            else
              login
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/volumes/#{vol_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete volume')
              logout
            end

            resource_update_status
          end
        end
      end

      def create_group_snapshot(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          if @basic_auth
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-groups", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create group snapshot ')
          else
            login
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-groups", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to create group snapshot ')
            logout
          end

          resource_update_status
        end
      end

      def delete_group_snapshot(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          snapshot_id = group_snapshot_id(sys_id, name)
          if snapshot_id.nil?
            false
          else
            if @basic_auth
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-groups/#{snapshot_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete group snapshot')
            else
              login
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-groups/#{snapshot_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete group snapshot')
              logout
            end

            resource_update_status
          end
        end
      end

      def create_volume_snapshot(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          if @basic_auth
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-volumes", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to delete group snapshot')
          else
            login
            response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-volumes", request_body.to_json)
            resource_update_status = status(response, '201', %w(201 200), 'Failed to delete group snapshot')
            logout
          end

          resource_update_status
        end
      end

      def delete_volume_snapshot(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        if sys_id.nil?
          false
        else
          snapshot_id = volume_snapshot_id(sys_id, name)
          if snapshot_id.nil?
            false
          else
            if @basic_auth
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-volumes/#{snapshot_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete group snapshot')
            else
              login
              response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-volumes/#{snapshot_id}")
              resource_update_status = status(response, '201', %w(201 200), 'Failed to delete group snapshot')
              logout
            end

            resource_update_status
          end
        end
      end

      private

      def storage_system_id(storage_system_ip)
        response = request(:get, '/devmgr/v2/storage-systems')
        storage_systems = JSON.parse(response.body)
        storage_systems.each do |system|
          return system['id'] if system['ip1'] == storage_system_ip || system['ip2'] == storage_system_ip
        end
        nil
      end

      def host_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/hosts")
        hosts = JSON.parse(response.body)
        hosts.each do |host|
          return host['id'] if host['label'] == name
        end
        nil
      end

      def host_group_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/host-groups")
        host_groups = JSON.parse(response.body)
        host_groups.each do |host_group|
          return host_group['id'] if host_group['label'] == name
        end
        nil
      end

      def storage_pool_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/storage-pools")
        storage_pools = JSON.parse(response.body)
        storage_pools.each do |pool|
          return pool['id'] if pool['label'] == name
        end
        nil
      end

      def volume_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/volumes")
        volumes = JSON.parse(response.body)
        volumes.each do |volume|
          return volume['id'] if volume['name'] == name
        end
        nil
      end

      def group_snapshot_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/snapshot-groups")
        snapshots = JSON.parse(response.body)
        snapshots.each do |snapshot|
          return snapshot['id'] if snapshot['label'] == name
        end
        nil
      end

      def volume_snapshot_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/snapshot-volumes")
        snapshots = JSON.parse(response.body)
        snapshots.each do |snapshot|
          return snapshot['id'] if snapshot['label'] == name
        end
        nil
      end

      def status(response, expected_status_code, allowed_status_codes, failure_message)
        request_fail = true
        resource_update_status = false

        allowed_status_codes.each do |status_code|
          if status_code == expected_status_code
            request_fail = false
            resource_update_status = true
            break
          end

          request_fail = false if response.status == status_code
        end

        request_fail ? (fail "#{failure_message}. HTTP error- #{response.status}") : resource_update_status
      end

      def request(method, path, body = nil)
        if @basic_auth
          Excon.send(method, @url, path: path, headers: web_proxy_headers, body: body, connect_timeout: @connect_timeout, user: @user, password: @password)
        else
          Excon.send(method, @url, path: path, headers: web_proxy_headers, body: body, connect_timeout: @connect_timeout)
        end
      end

      def web_proxy_headers
        if @basic_auth
          { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
        else
          { 'Accept' => 'application/json', 'Content-Type' => 'application/json', 'cookie' => @cookie }
        end
      end

      def login
        body = { userId: @user, password: @password }.to_json
        response = request(:post, '/devmgr/utils/login', body.to_json)
        fail "Login failed. HTTP error- #{response.status}" if response.status != 200
        @cookie = response.headers['Set-Cookie'].split(';').first
      end

      def logout
        body = { userId: @user, password: @password }.to_json
        response = request(:delete, '/devmgr/utils/login', body.to_json)
        fail "Logout failed. HTTP error- #{response.status}" if response.status != 204
        @cookie = nil
      end
    end
  end
end
