require 'json'
require 'excon'

class NetApp
  class ESeries
    class Api
      def initialize(user, password, url, basic_auth, connect_timeout = nil)
        @user = user
        @password = password
        @url = url
        @basic_auth = basic_auth
        @connect_timeout = connect_timeout
      end

      def login
        body = { userId: @user, password: @password }.to_json
        response = request(:post, '/devmgr/utils/login', body)
        fail "Login failed. HTTP error- #{response.status}" if response.status != 200
        @cookie = response.headers['Set-Cookie'].split(';').first
      end

      def logout
        response = request(:delete, '/devmgr/utils/login')
        fail "Logout failed. HTTP error- #{response.status}" if response.status != 204
        @cookie = nil
      end

      def create_storage_system(request_body)
        return false unless storage_system_id(request_body[:controllerAddresses][0]).nil?

        response = request(:post, '/devmgr/v2/storage-systems', request_body.to_json)
        status(response, 201, [201, 200], 'Storage Creation Failed')
      end

      def delete_storage_system(storage_system_ip)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}")
        status(response, 200, [200], 'Storage Deletion Failed')
      end

      def change_password(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/passwords", request_body.to_json)
        status(response, 200, [200], 'Password Update Failed')
      end

      def create_host(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        host = host_id(sys_id, request_body[:name])
        return false unless host.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/hosts", request_body.to_json)
        status(response, 201, [201], 'Failed to create host')
      end

      def delete_host(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        host = host_id(sys_id, name)
        return false if host.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/hosts/#{host}")
        status(response, 200, [200], 'Failed to delete host')
      end

      def create_host_group(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        host_grp_id = host_group_id(sys_id, request_body[:name])
        return false unless host_grp_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/host-groups", request_body.to_json)
        status(response, 201, [201], 'Failed to create host group')
      end

      def delete_host_group(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        host_grp_id = host_group_id(sys_id, name)
        return false if host_grp_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/host-groups/#{host_grp_id}")
        status(response, 200, [200], 'Failed to delete host group')
      end

      def create_storage_pool(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        pool_id = storage_pool_id(sys_id, request_body[:name])
        return false unless pool_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/storage-pools", request_body.to_json)
        status(response, 201, [201], 'Failed to create storage pool')
      end

      def delete_storage_pool(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        pool_id = storage_pool_id(sys_id, name)
        return false if pool_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/storage-pools/#{pool_id}")
        status(response, 200, [200], 'Failed to delete storage pool')
      end

      def create_volume(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        vol_id = volume_id(sys_id, request_body[:name])
        return false unless vol_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/volumes", request_body.to_json)
        status(response, 201, [201], 'Failed to create volume')
      end

      def update_volume(storage_system_ip, old_name, new_name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        vol_id = volume_id(sys_id, old_name)
        return false if vol_id.nil?

        body = { name: new_name }.to_json
        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/volumes/#{vol_id}", body)
        status(response, 200, [200], 'Failed to update volume')
      end

      def delete_volume(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        vol_id = volume_id(sys_id, name)
        return false if vol_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/volumes/#{vol_id}")
        status(response, 200, [200], 'Failed to delete volume')
      end

      def create_group_snapshot(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        snapshot_id = group_snapshot_id(sys_id, request_body[:name])
        return false unless snapshot_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-groups", request_body.to_json)
        status(response, 201, [201], 'Failed to create group snapshot')
      end

      def delete_group_snapshot(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        snapshot_id = group_snapshot_id(sys_id, name)
        return false if snapshot_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-groups/#{snapshot_id}")
        status(response, 200, [200], 'Failed to delete group snapshot')
      end

      def create_volume_snapshot(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        snapshot_id = volume_snapshot_id(sys_id, request_body[:name])
        return false unless snapshot_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-volumes", request_body.to_json)
        status(response, 201, [201], 'Failed to create volume snapshot')
      end

      def delete_volume_snapshot(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        snapshot_id = volume_snapshot_id(sys_id, name)
        return false if snapshot_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-volumes/#{snapshot_id}")
        status(response, 200, [200], 'Failed to delete volume snapshot')
      end

      def update_iscsi(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/iscsi/target-settings", request_body.to_json)
        status(response, 200, [200], 'Failed to update iscsi target settings')
      end

      def create_thin_volume(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        volume_id = thin_volume_id(sys_id, request_body[:name])
        return false unless volume_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/thin-volumes", request_body.to_json)
        status(response, 201, [201], 'Failed to create thin volume')
      end

      def delete_thin_volume(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        volume_id = thin_volume_id(sys_id, name)
        return false if volume_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/thin-volumes/#{volume_id}")
        status(response, 200, [200], 'Failed to delete thin volume')
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

      def thin_volume_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/thin-volumes")
        volumes = JSON.parse(response.body)
        volumes.each do |volume|
          return volume['id'] if volume['name'] == name
        end
        nil
      end

      def volume_group_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/storage-pools")
        groups = JSON.parse(response.body)
        groups.each do |group|
          return group['id'] if group['label'] == name
        end
        nil
      end

      def status(response, expected_status_code, allowed_status_codes, failure_message)
        request_fail = true
        resource_update_status = false

        if response.status == expected_status_code
          request_fail = false
          resource_update_status = true
        else
          allowed_status_codes.each do |status_code|
            next if response.status != status_code
            request_fail = false
            break
          end
        end
        request_fail ? (fail "#{failure_message}.\n\n#{response.body}") : resource_update_status
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
    end
  end
end
