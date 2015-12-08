require 'json'
require 'excon'

class NetApp
  class ESeries
    class Api
      # user, password, url, basic_auth, asup, connect_timeout = nil
      def initialize(options = {})
        @user = options[:user]
        @password = options[:password]
        @url = options[:url]
        @basic_auth = options[:basic_auth]
        @asup = options[:asup]
        @connect_timeout = options[:connect_timeout]
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

      # Call storage system API /devmgr/v2/storage-systems to add a new storage system
      def create_storage_system(request_body)
        return false unless storage_system_id(request_body[:controllerAddresses][0]).nil?

        response = request(:post, '/devmgr/v2/storage-systems', request_body.to_json)
        status(response, 201, [201, 200], 'Storage Creation Failed')
      end

      # Call storage system API /devmgr/v2/storage-systems/{storage-system-id} to remove the storage system
      def delete_storage_system(storage_system_ip)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}")
        status(response, 200, [200], 'Storage Deletion Failed')
      end

      # Call storage system API /devmgr/v2/{storage-system-id}/passwords to change the password of the storage system
      def change_password(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/passwords", request_body.to_json)
        status(response, 200, [200], 'Password Update Failed')
      end

      # Call host API /devmgr/v2/{storage-system-id}/hosts to add a host
      def create_host(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        host = host_id(sys_id, request_body[:name])
        return false unless host.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/hosts", request_body.to_json)
        status(response, 201, [201], 'Failed to create host')
      end

      # Call host API /devmgr/v2/{storage-system-id}/hosts/{host-id} to remove a host
      def delete_host(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        host = host_id(sys_id, name)
        return false if host.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/hosts/#{host}")
        status(response, 200, [200], 'Failed to delete host')
      end

      # Call host-group API /devmgr/v2/{storage-system-id}/host-groups to add a host-group
      def create_host_group(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        host_grp_id = host_group_id(sys_id, request_body[:name])
        return false unless host_grp_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/host-groups", request_body.to_json)
        status(response, 201, [201], 'Failed to create host group')
      end

      # Call host-group API /devmgr/v2/{storage-system-id}/host-groups/{host-group-id} to remove a host-group
      def delete_host_group(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        host_grp_id = host_group_id(sys_id, name)
        return false if host_grp_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/host-groups/#{host_grp_id}")
        status(response, 200, [200], 'Failed to delete host group')
      end

      # Call storage-pool API /devmgr/v2/{storage-system-id}/storage-pools to create a volume group or a disk pool.
      # Disk pool can be created only with raid level 'raidDiskPool'.
      def create_storage_pool(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        pool_id = storage_pool_id(sys_id, request_body[:name])
        return false unless pool_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/storage-pools", request_body.to_json)
        status(response, 201, [201], 'Failed to create storage pool')
      end

      # Call storage-pool API /devmgr/v2/{storage-system-id}/storage-pools/{storage-pool-id} to delete a volume group or a disk pool.
      def delete_storage_pool(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        pool_id = storage_pool_id(sys_id, name)
        return false if pool_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/storage-pools/#{pool_id}")
        status(response, 200, [200], 'Failed to delete storage pool')
      end

      # Call volume API /devmgr/v2/{storage-system-id}/volumes to create a new volume.
      def create_volume(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        vol_id = volume_id(sys_id, request_body[:name])
        return false unless vol_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/volumes", request_body.to_json)
        status(response, 201, [201], 'Failed to create volume')
      end

      # Call volume API /devmgr/v2/{storage-system-id}/volumes/{volume-id} to update volume attributes.
      def update_volume(storage_system_ip, old_name, new_name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        vol_id = volume_id(sys_id, old_name)
        return false if vol_id.nil?

        body = { name: new_name }.to_json
        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/volumes/#{vol_id}", body)
        status(response, 200, [200], 'Failed to update volume')
      end

      # Call volume API /devmgr/v2/{storage-system-id}/volumes/{volume-id} to delete a volume.
      def delete_volume(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        vol_id = volume_id(sys_id, name)
        return false if vol_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/volumes/#{vol_id}")
        status(response, 200, [200], 'Failed to delete volume')
      end

      # Call group snapshot API /devmgr/v2/{storage-system-id}/group-snapshots/ create a group snapshot.
      def create_group_snapshot(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        snapshot_id = group_snapshot_id(sys_id, request_body[:name])
        return false unless snapshot_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-groups", request_body.to_json)
        status(response, 201, [201], 'Failed to create group snapshot')
      end

      # Call group snapshot API /devmgr/v2/{storage-system-id}/group-snapshots/{group-snapshot-id} delete a group snapshot.
      def delete_group_snapshot(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        snapshot_id = group_snapshot_id(sys_id, name)
        return false if snapshot_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-groups/#{snapshot_id}")
        status(response, 200, [200], 'Failed to delete group snapshot')
      end

      # Call volume snapshot API /devmgr/v2/{storage-system-id}/volume-snapshots create a volume snapshot.
      def create_volume_snapshot(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        snapshot_id = volume_snapshot_id(sys_id, request_body[:name])
        return false unless snapshot_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-volumes", request_body.to_json)
        status(response, 201, [201], 'Failed to create volume snapshot')
      end

      # Call volume snapshot API /devmgr/v2/{storage-system-id}/volume-snapshots/{volume-snapshot-id} delete a volume snapshot.
      def delete_volume_snapshot(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        snapshot_id = volume_snapshot_id(sys_id, name)
        return false if snapshot_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/snapshot-volumes/#{snapshot_id}")
        status(response, 200, [200], 'Failed to delete volume snapshot')
      end

      # Call Mirroring API /devmgr/v2/storage-systems/systemId/Async-mirrors to add a new mirror group
      def create_mirror_group(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        mirror_group_id = mirror_group_id(sys_id, request_body[:name])
        return false unless mirror_group_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/async-mirrors", request_body.to_json)
        status(response, 201, [201], 'Failed to create mirror group')
      end

      # Call Mirroring API to remove mirror group
      def delete_mirror_group(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        mirror_group_id = mirror_group_id(sys_id, name)
        return false if mirror_group_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/async-mirrors/#{mirror_group_id}")
        status(response, 200, [200], 'Failed to delete mirror group')
      end

      # Call iscsi API /devmgr/v2/{storage-system-id}//iscsi/target-settings to update iscsi settings.
      def update_iscsi(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/iscsi/target-settings", request_body.to_json)
        status(response, 200, [200], 'Failed to update iscsi target settings')
      end

      # Call thin volume API /devmgr/v2/{storage-system-id}/thin-volumes to create a thin volume
      def create_thin_volume(storage_system_ip, request_body)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        volume_id = thin_volume_id(sys_id, request_body[:name])
        return false unless volume_id.nil?

        response = request(:post, "/devmgr/v2/storage-systems/#{sys_id}/thin-volumes", request_body.to_json)
        status(response, 201, [201], 'Failed to create thin volume')
      end

      # Call thin volume API /devmgr/v2/{storage-system-id}/thin-volumes/{thin-volume-id} to delete a thin volume
      def delete_thin_volume(storage_system_ip, name)
        sys_id = storage_system_id(storage_system_ip)
        return false if sys_id.nil?

        volume_id = thin_volume_id(sys_id, name)
        return false if volume_id.nil?

        response = request(:delete, "/devmgr/v2/storage-systems/#{sys_id}/thin-volumes/#{volume_id}")
        status(response, 200, [200], 'Failed to delete thin volume')
      end

      # Post key/value pair to proxy for inclusion in ASUP bundle
      def post_key_value(key, value)
        response = request(:post, "/devmgr/v2/key-values/#{key}", value)
        status(response, 200, [200], 'Failed to post key/value pair')
      end

      # Send ASUP key/value pair for tracking
      def send_asup
        client_info = { 'application'  => 'Chef',
                        'chef-version' => Chef::VERSION,
                        'url'          => @url
                      }.to_json if @asup

        post_key_value('Chef', client_info) if @asup
      end

      private

      # Get the storage-system-id using storage syste ip
      def storage_system_id(storage_system_ip)
        response = request(:get, '/devmgr/v2/storage-systems')
        storage_systems = JSON.parse(response.body)
        storage_systems.each do |system|
          return system['id'] if system['ip1'] == storage_system_ip || system['ip2'] == storage_system_ip
        end
        nil
      end

      # Get the host-id using storage-system-ip and host name
      def host_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/hosts")
        hosts = JSON.parse(response.body)
        hosts.each do |host|
          return host['id'] if host['label'] == name
        end
        nil
      end

      # Get the host-group-id using storage-system-ip and host-group name
      def host_group_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/host-groups")
        host_groups = JSON.parse(response.body)
        host_groups.each do |host_group|
          return host_group['id'] if host_group['label'] == name
        end
        nil
      end

      # Get the storage-pool-id using storage-system-ip and storage-pool name
      def storage_pool_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/storage-pools")
        storage_pools = JSON.parse(response.body)
        storage_pools.each do |pool|
          return pool['id'] if pool['label'] == name
        end
        nil
      end

      # Get the volume-id using storage-system-ip and volume name
      def volume_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/volumes")
        volumes = JSON.parse(response.body)
        volumes.each do |volume|
          return volume['id'] if volume['name'] == name
        end
        nil
      end

      # Get the group-snapshot-id using storage-system-ip and group-snapshot name
      def group_snapshot_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/snapshot-groups")
        snapshots = JSON.parse(response.body)
        snapshots.each do |snapshot|
          return snapshot['id'] if snapshot['label'] == name
        end
        nil
      end

      # Get the volume-snapshot-id using storage-system-ip and volume-snapshot name
      def volume_snapshot_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/snapshot-volumes")
        snapshots = JSON.parse(response.body)
        snapshots.each do |snapshot|
          return snapshot['id'] if snapshot['label'] == name
        end
        nil
      end

      # Get the thin-volume-id using storage-system-ip and thin-volume name
      def thin_volume_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/thin-volumes")
        volumes = JSON.parse(response.body)
        volumes.each do |volume|
          return volume['id'] if volume['name'] == name
        end
        nil
      end

      # Get the mirror id using storage-system-ip and async-mirrors
      def mirror_group_id(storage_sys_id, name)
        response = request(:get, "/devmgr/v2/storage-systems/#{storage_sys_id}/async-mirrors")
        mirrors = JSON.parse(response.body)
        mirrors.each do |mirror|
          return mirror['id'] if mirror['label'] == name
        end
        nil
      end

      # Determine the status of the resource:
      # True - Resource was updated
      # False - Resource exists in the desired state.
      # Exception- An error occurred due to incorrect resource attributes or system settings.
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

      # Make a call to the web proxy
      def request(method, path, body = nil)
        if @basic_auth
          Excon.send(method, @url, path: path, headers: web_proxy_headers, body: body, connect_timeout: @connect_timeout, user: @user, password: @password)
        else
          Excon.send(method, @url, path: path, headers: web_proxy_headers, body: body, connect_timeout: @connect_timeout)
        end
      end

      # Set headers for web proxy.
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
