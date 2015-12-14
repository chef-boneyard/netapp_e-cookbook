require_relative '../libraries/netapp_e_series_api'

describe 'netapp_e_series_api' do
  before do
    params = {  user: 'rw', password: 'rw',
                url: '127.0.0.1', basic_auth: true,
                asup: true
              }

    @netapp_api = NetApp::ESeries::Api.new(params)
  end

  context 'login:' do
    before do
      @body = { userId: 'rw', password: 'rw' }.to_json
    end

    it 'succeeds when credentials are correct' do
      response = double(body: 'success', headers: { 'Set-Cookie' => 'JSESSIONID=vsek549xg1021l2rz513qvrr;Path=/devmgr' }, status: 200)

      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/utils/login', @body).and_return(response)
      @netapp_api.login
      expect(@netapp_api.instance_variable_get(:@cookie)).to eq('JSESSIONID=vsek549xg1021l2rz513qvrr')
    end

    it 'fails when credentials are wrong' do
      response = double(body: 'fail', headers: { 'Set-Cookie' => 'JSESSIONID=vsek549xg1021l2rz513qvrr;Path=/devmgr' }, status: 401)

      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/utils/login', @body).and_return(response)
      expect { @netapp_api.login }.to raise_exception
    end
  end

  context 'logout:' do
    before do
      @body = { userId: 'rw', password: 'rw' }.to_json
    end

    it 'succeeds' do
      response = double(body: 'success', headers: { 'Set-Cookie' => 'JSESSIONID=vsek549xg1021l2rz513qvrr;Path=/devmgr' }, status: 200)

      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/utils/login', @body).and_return(response)
      @netapp_api.login
      expect(@netapp_api.instance_variable_get(:@cookie)).to eq('JSESSIONID=vsek549xg1021l2rz513qvrr')
    end

    it 'fails' do
      response = double(body: 'fail', headers: { 'Set-Cookie' => 'JSESSIONID=vsek549xg1021l2rz513qvrr;Path=/devmgr' }, status: 401)

      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/utils/login', @body).and_return(response)
      expect { @netapp_api.login }.to raise_exception
    end
  end

  context 'status:' do
    it 'is true when resource is updated' do
      response = double(body: 'success', headers: { 'Set-Cookie' => 'JSESSIONID=vsek549xg1021l2rz513qvrr;Path=/devmgr' }, status: 201)

      expect(@netapp_api.send(:status, response, 201, [200, 201], 'method failed')).to eq(true)
    end

    it 'is false when the resource is not updated' do
      response = double(body: 'success', headers: { 'Set-Cookie' => 'JSESSIONID=vsek549xg1021l2rz513qvrr;Path=/devmgr' }, status: 200)

      expect(@netapp_api.send(:status, response, 201, [201, 200], 'method failed')).to eq(false)
    end

    it 'is raises exception' do
      response = double(body: 'Failed', headers: { 'Set-Cookie' => 'JSESSIONID=vsek549xg1021l2rz513qvrr;Path=/devmgr' }, status: 422)

      expect { @netapp_api.send(:status, response, 201, [201, 200], 'method failed') }.to raise_exception
    end
  end

  context 'request and web proxy headers:' do
    it 'when basic authentication is set to true' do
      headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }

      expect(Excon).to receive(:get).with('127.0.0.1', path: '/devmgr/v2/storage-systems', headers: headers, body: "{\"ip\":\"10.0.0.1\"}", connect_timeout: nil, user: 'rw', password: 'rw')

      @netapp_api.send(:request, :get, '/devmgr/v2/storage-systems', "{\"ip\":\"10.0.0.1\"}")
    end

    it 'when basic authentication is set to false' do
      params = {  user: 'rw', password: 'rw',
                  url: '127.0.0.1', basic_auth: false,
                  asup: true
                }

      @netapp_api_no_basic_auth = NetApp::ESeries::Api.new(params)
      headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json', 'cookie' => @cookie }

      expect(Excon).to receive(:get).with('127.0.0.1', path: '/devmgr/v2/storage-systems', headers: headers, body: "{\"ip\":\"10.0.0.1\"}", connect_timeout: nil)

      @netapp_api_no_basic_auth.send(:request, :get, '/devmgr/v2/storage-systems', "{\"ip\":\"10.0.0.1\"}")
    end
  end

  context 'storage_system:' do
    it 'is created' do
      response = double
      request_body = "{\"controllerAddresses\":[\"10.0.0.1\"]}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201, 200], 'Storage Creation Failed')

      @netapp_api.create_storage_system(controllerAddresses: ['10.0.0.1'])
    end

    it 'return false when storage system exists (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')

      expect(@netapp_api.create_storage_system(controllerAddresses: ['10.0.0.1'])).to eq(false)
    end

    it 'is deleted when the storage system exists' do
      response = double

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Storage Deletion Failed')

      @netapp_api.delete_storage_system('10.0.0.1')
    end

    it 'return false if the storage system does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_storage_system('10.0.0.1')).to eq(false)
    end
  end

  context 'change password:' do
    it 'when storage exists ' do
      response = double
      request_body = "{\"newPassword\":\"Netapp123\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/passwords', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Password Update Failed')

      @netapp_api.change_password('10.0.0.1', newPassword: 'Netapp123')
    end

    it 'fails when storage does not exist' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.change_password('10.0.0.1', newPassword: 'Netapp123')).to eq(false)
    end
  end

  context 'host:' do
    it 'is created' do
      response = double
      request_body = "{\"name\":\"demo_host\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:host_id).with('12345', 'demo_host').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/hosts', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201], 'Failed to create host')

      @netapp_api.create_host('10.0.0.1', name: 'demo_host')
    end

    it 'return false when storage system does not exist (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.create_host('10.0.0.1', name: 'demo_host')).to eq(false)
    end

    it 'return false when host exists (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:host_id).with('12345', 'demo_host').and_return('111111')

      expect(@netapp_api.create_host('10.0.0.1', name: 'demo_host')).to eq(false)
    end

    it 'is deleted' do
      response = double

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:host_id).with('12345', 'demo_host').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/hosts/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to delete host')

      @netapp_api.delete_host('10.0.0.1', 'demo_host')
    end

    it 'return false when the storage system does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_host('10.0.0.1', 'demo_host')).to eq(false)
    end

    it 'return false when host does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:host_id).with('12345', 'demo_host').and_return(nil)

      expect(@netapp_api.delete_host('10.0.0.1', 'demo_host')).to eq(false)
    end
  end

  context 'host_group:' do
    it 'is created' do
      response = double
      request_body = "{\"name\":\"demo_host_group\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:host_group_id).with('12345', 'demo_host_group').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/host-groups', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201], 'Failed to create host group')

      @netapp_api.create_host_group('10.0.0.1', name: 'demo_host_group')
    end

    it 'return false when storage system does not exist (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.create_host_group('10.0.0.1', name: 'demo_host_group')).to eq(false)
    end

    it 'return false when host group exists (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:host_group_id).with('12345', 'demo_host_group').and_return('111111')

      expect(@netapp_api.create_host_group('10.0.0.1', name: 'demo_host_group')).to eq(false)
    end

    it 'is deleted' do
      response = double

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:host_group_id).with('12345', 'demo_host_group').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/host-groups/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to delete host group')

      @netapp_api.delete_host_group('10.0.0.1', 'demo_host_group')
    end

    it 'return false when the storage system does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_host_group('10.0.0.1', 'demo_host_group')).to eq(false)
    end

    it 'return false when host group does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:host_group_id).with('12345', 'demo_host_group').and_return(nil)

      expect(@netapp_api.delete_host_group('10.0.0.1', 'demo_host_group')).to eq(false)
    end
  end

  context 'storage_pool:' do
    it 'is created' do
      response = double
      request_body = "{\"name\":\"demo_storage_pool\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:storage_pool_id).with('12345', 'demo_storage_pool').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/storage-pools', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201], 'Failed to create storage pool')

      @netapp_api.create_storage_pool('10.0.0.1', name: 'demo_storage_pool')
    end

    it 'return false when storage system does not exist (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.create_storage_pool('10.0.0.1', name: 'demo_storage_pool')).to eq(false)
    end

    it 'return false when storage pool exists (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:storage_pool_id).with('12345', 'demo_storage_pool').and_return('111111')

      expect(@netapp_api.create_storage_pool('10.0.0.1', name: 'demo_storage_pool')).to eq(false)
    end

    it 'is deleted' do
      response = double

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:storage_pool_id).with('12345', 'demo_storage_pool').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/storage-pools/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to delete storage pool')

      @netapp_api.delete_storage_pool('10.0.0.1', 'demo_storage_pool')
    end

    it 'return false when the storage system does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_storage_pool('10.0.0.1', 'demo_storage_pool')).to eq(false)
    end

    it 'return false when storage pool does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:storage_pool_id).with('12345', 'demo_storage_pool').and_return(nil)

      expect(@netapp_api.delete_storage_pool('10.0.0.1', 'demo_storage_pool')).to eq(false)
    end
  end

  context 'volume:' do
    it 'is created' do
      response = double
      request_body = "{\"name\":\"demo_volume\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_id).with('12345', 'demo_volume').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/volumes', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201], 'Failed to create volume')

      @netapp_api.create_volume('10.0.0.1', name: 'demo_volume')
    end

    it 'return false when storage system does not exist (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.create_volume('10.0.0.1', name: 'demo_volume')).to eq(false)
    end

    it 'return false when storage pool exists (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_id).with('12345', 'demo_volume').and_return('111111')

      expect(@netapp_api.create_volume('10.0.0.1', name: 'demo_volume')).to eq(false)
    end

    it 'is deleted' do
      response = double

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_id).with('12345', 'demo_volume').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/volumes/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to delete volume')

      @netapp_api.delete_volume('10.0.0.1', 'demo_volume')
    end

    it 'return false when the storage system does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_volume('10.0.0.1', 'demo_volume')).to eq(false)
    end

    it 'return false when storage pool does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_id).with('12345', 'demo_volume').and_return(nil)

      expect(@netapp_api.delete_volume('10.0.0.1', 'demo_volume')).to eq(false)
    end

    it 'is updated' do
      response = double
      request_body = "{\"name\":\"demo_vol\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_id).with('12345', 'demo_volume').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/volumes/111111', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to update volume')

      @netapp_api.update_volume('10.0.0.1', 'demo_volume', 'demo_vol')
    end

    it 'return false when the storage system does not exist (update)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.update_volume('10.0.0.1', 'demo_volume', 'demo_vol')).to eq(false)
    end

    it 'return false when storage pool does not exist (update)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_id).with('12345', 'demo_volume').and_return(nil)

      expect(@netapp_api.update_volume('10.0.0.1', 'demo_volume', 'demo_vol')).to eq(false)
    end
  end

  context 'group_snapshot:' do
    it 'is created' do
      response = double
      request_body = "{\"name\":\"demo_group_snapshot\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:group_snapshot_id).with('12345', 'demo_group_snapshot').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/snapshot-groups', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201], 'Failed to create group snapshot')

      @netapp_api.create_group_snapshot('10.0.0.1', name: 'demo_group_snapshot')
    end

    it 'return false when storage system does not exist (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.create_group_snapshot('10.0.0.1', name: 'demo_group_snapshot')).to eq(false)
    end

    it 'return false when group snapshot exists (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:group_snapshot_id).with('12345', 'demo_group_snapshot').and_return('111111')

      expect(@netapp_api.create_group_snapshot('10.0.0.1', name: 'demo_group_snapshot')).to eq(false)
    end

    it 'is deleted' do
      response = double

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:group_snapshot_id).with('12345', 'demo_group_snapshot').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/snapshot-groups/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to delete group snapshot')

      @netapp_api.delete_group_snapshot('10.0.0.1', 'demo_group_snapshot')
    end

    it 'return false when the storage system does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_group_snapshot('10.0.0.1', 'demo_group_snapshot')).to eq(false)
    end

    it 'return false when group snapshot does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:group_snapshot_id).with('12345', 'demo_group_snapshot').and_return(nil)

      expect(@netapp_api.delete_group_snapshot('10.0.0.1', 'demo_group_snapshot')).to eq(false)
    end
  end

  context 'volume_snapshot:' do
    it 'is created' do
      response = double
      request_body = "{\"name\":\"demo_volume_snapshot\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_snapshot_id).with('12345', 'demo_volume_snapshot').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/snapshot-volumes', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201], 'Failed to create volume snapshot')

      @netapp_api.create_volume_snapshot('10.0.0.1', name: 'demo_volume_snapshot')
    end

    it 'return false when storage system does not exist (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.create_volume_snapshot('10.0.0.1', name: 'demo_volume_snapshot')).to eq(false)
    end

    it 'return false when group snapshot exists (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_snapshot_id).with('12345', 'demo_volume_snapshot').and_return('111111')

      expect(@netapp_api.create_volume_snapshot('10.0.0.1', name: 'demo_volume_snapshot')).to eq(false)
    end

    it 'is deleted' do
      response = double

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_snapshot_id).with('12345', 'demo_volume_snapshot').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/snapshot-volumes/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to delete volume snapshot')

      @netapp_api.delete_volume_snapshot('10.0.0.1', 'demo_volume_snapshot')
    end

    it 'return false when the storage system does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_volume_snapshot('10.0.0.1', 'demo_volume_snapshot')).to eq(false)
    end

    it 'return false when group snapshot does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_snapshot_id).with('12345', 'demo_volume_snapshot').and_return(nil)

      expect(@netapp_api.delete_volume_snapshot('10.0.0.1', 'demo_volume_snapshot')).to eq(false)
    end
  end

  context 'thin_volume:' do
    it 'is created' do
      response = double
      request_body = "{\"name\":\"demo_thin_volume\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:thin_volume_id).with('12345', 'demo_thin_volume').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/thin-volumes', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201], 'Failed to create thin volume')

      @netapp_api.create_thin_volume('10.0.0.1', name: 'demo_thin_volume')
    end

    it 'return false when storage system does not exist (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.create_thin_volume('10.0.0.1', name: 'demo_thin_volume')).to eq(false)
    end

    it 'return false when group snapshot exists (create)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:thin_volume_id).with('12345', 'demo_thin_volume').and_return('111111')

      expect(@netapp_api.create_thin_volume('10.0.0.1', name: 'demo_thin_volume')).to eq(false)
    end

    it 'is deleted' do
      response = double

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:thin_volume_id).with('12345', 'demo_thin_volume').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/thin-volumes/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to delete thin volume')

      @netapp_api.delete_thin_volume('10.0.0.1', 'demo_thin_volume')
    end

    it 'return false when the storage system does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_thin_volume('10.0.0.1', 'demo_thin_volume')).to eq(false)
    end

    it 'return false when group snapshot does not exist (delete)' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:thin_volume_id).with('12345', 'demo_thin_volume').and_return(nil)

      expect(@netapp_api.delete_thin_volume('10.0.0.1', 'demo_thin_volume')).to eq(false)
    end
  end

  context 'iscsi:' do
    it 'is updated' do
      response = double
      request_body = "{\"alias\":\"iscsi_new\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/iscsi/target-settings', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to update iscsi target settings')

      @netapp_api.update_iscsi('10.0.0.1', alias: 'iscsi_new')
    end

    it 'return false when the storage system does not exist' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.update_iscsi('10.0.0.1', alias: 'iscsi_new')).to eq(false)
    end
  end

  context 'storage_system_id:' do
    it 'returns id when storage system exists' do
      response = double(body: "[{\"ip1\":\"10.0.0.1\",\"ip2\":\"10.0.0.2\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems').and_return(response)
      expect(@netapp_api.send(:storage_system_id, '10.0.0.1')).to eq('111111')
    end

    it 'returns nil when no storage systems exist' do
      response = double(body: '[]')

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems').and_return(response)
      expect(@netapp_api.send(:storage_system_id, '10.0.0.1')).to eq(nil)
    end

    it 'returns nil when required storage system does not exist' do
      response = double(body: "[{\"ip1\":\"10.10.10.1\",\"ip2\":\"10.10.10.2\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems').and_return(response)
      expect(@netapp_api.send(:storage_system_id, '10.0.0.1')).to eq(nil)
    end
  end

  context 'host_id:' do
    it 'returns id when host exits' do
      response = double(body: "[{\"label\":\"demo_host\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/hosts').and_return(response)
      expect(@netapp_api.send(:host_id, '12345', 'demo_host')).to eq('111111')
    end

    it 'returns nil when no hosts exist' do
      response = double(body: '[]')

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/hosts').and_return(response)
      expect(@netapp_api.send(:host_id, '12345', 'demo_host')).to eq(nil)
    end

    it 'returns nil when the required host does not exist' do
      response = double(body: "[{\"label\":\"demo_host_1\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/hosts').and_return(response)
      expect(@netapp_api.send(:host_id, '12345', 'demo_host')).to eq(nil)
    end
  end

  context 'host_group_id:' do
    it 'returns id when host exits' do
      response = double(body: "[{\"label\":\"demo_host_group\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/host-groups').and_return(response)
      expect(@netapp_api.send(:host_group_id, '12345', 'demo_host_group')).to eq('111111')
    end

    it 'returns nil when no hosts exist' do
      response = double(body: '[]')

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/host-groups').and_return(response)
      expect(@netapp_api.send(:host_group_id, '12345', 'demo_host_group')).to eq(nil)
    end

    it 'returns nil when the required host does not exist' do
      response = double(body: "[{\"label\":\"demo_host_group_1\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/host-groups').and_return(response)
      expect(@netapp_api.send(:host_group_id, '12345', 'demo_host_group')).to eq(nil)
    end
  end

  context 'storage_pool_id:' do
    it 'returns id when host exits' do
      response = double(body: "[{\"label\":\"demo_pool\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/storage-pools').and_return(response)
      expect(@netapp_api.send(:storage_pool_id, '12345', 'demo_pool')).to eq('111111')
    end

    it 'returns nil when no hosts exist' do
      response = double(body: '[]')

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/storage-pools').and_return(response)
      expect(@netapp_api.send(:storage_pool_id, '12345', 'demo_pool')).to eq(nil)
    end

    it 'returns nil when the required host does not exist' do
      response = double(body: "[{\"label\":\"demo_pool_1\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/storage-pools').and_return(response)
      expect(@netapp_api.send(:storage_pool_id, '12345', 'demo_pool')).to eq(nil)
    end
  end

  context 'volume_id:' do
    it 'returns id when host exits' do
      response = double(body: "[{\"name\":\"demo_volume\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/volumes').and_return(response)
      expect(@netapp_api.send(:volume_id, '12345', 'demo_volume')).to eq('111111')
    end

    it 'returns nil when no hosts exist' do
      response = double(body: '[]')

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/volumes').and_return(response)
      expect(@netapp_api.send(:volume_id, '12345', 'demo_volume')).to eq(nil)
    end

    it 'returns nil when the required host does not exist' do
      response = double(body: "[{\"name\":\"demo_volume_1\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/volumes').and_return(response)
      expect(@netapp_api.send(:volume_id, '12345', 'demo_volume')).to eq(nil)
    end
  end

  context 'group_snapshot_id:' do
    it 'returns id when host exits' do
      response = double(body: "[{\"label\":\"demo_group_snapshot\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/snapshot-groups').and_return(response)
      expect(@netapp_api.send(:group_snapshot_id, '12345', 'demo_group_snapshot')).to eq('111111')
    end

    it 'returns nil when no hosts exist' do
      response = double(body: '[]')

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/snapshot-groups').and_return(response)
      expect(@netapp_api.send(:group_snapshot_id, '12345', 'demo_group_snapshot')).to eq(nil)
    end

    it 'returns nil when the required host does not exist' do
      response = double(body: "[{\"label\":\"demo_group_snapshot_1\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/snapshot-groups').and_return(response)
      expect(@netapp_api.send(:group_snapshot_id, '12345', 'demo_group_snapshot')).to eq(nil)
    end
  end

  context 'volume_snapshot_id:' do
    it 'returns id when host exits' do
      response = double(body: "[{\"label\":\"demo_snapshot_volume\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/snapshot-volumes').and_return(response)
      expect(@netapp_api.send(:volume_snapshot_id, '12345', 'demo_snapshot_volume')).to eq('111111')
    end

    it 'returns nil when no hosts exist' do
      response = double(body: '[]')

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/snapshot-volumes').and_return(response)
      expect(@netapp_api.send(:volume_snapshot_id, '12345', 'demo_snapshot_volume')).to eq(nil)
    end

    it 'returns nil when the required host does not exist' do
      response = double(body: "[{\"label\":\"demo_snapshot_volume_1\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/snapshot-volumes').and_return(response)
      expect(@netapp_api.send(:volume_snapshot_id, '12345', 'demo_snapshot_volume')).to eq(nil)
    end
  end

  context 'thin_volume_id:' do
    it 'returns id when host exits' do
      response = double(body: "[{\"name\":\"demo_thin_volume\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/thin-volumes').and_return(response)
      expect(@netapp_api.send(:thin_volume_id, '12345', 'demo_thin_volume')).to eq('111111')
    end

    it 'returns nil when no hosts exist' do
      response = double(body: '[]')

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/thin-volumes').and_return(response)
      expect(@netapp_api.send(:thin_volume_id, '12345', 'demo_thin_volume')).to eq(nil)
    end

    it 'returns nil when the required host does not exist' do
      response = double(body: "[{\"name\":\"demo_thin_volume_1\",\"id\":\"111111\"}]")

      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/thin-volumes').and_return(response)
      expect(@netapp_api.send(:thin_volume_id, '12345', 'demo_thin_volume')).to eq(nil)
    end
  end

  context 'test_asup_positive' do
    it 'send asup to proxy' do
      response = double
      stub_const('Chef::VERSION', '12.4.1')
      request_body = "{\"application\":\"Chef\",\"chef-version\":\"12.4.1\",\"url\":\"127.0.0.1\"}"

      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/key-values/Chef', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to post key/value pair')

      @netapp_api.send_asup
    end
  end

  context 'test_asup_negative' do
    before do
      params = {  user: 'rw', password: 'rw',
                  url: '127.0.0.1', basic_auth: true,
                  asup: false
                }

      @netapp_api = NetApp::ESeries::Api.new(params)
    end

    it 'does nothing' do
      expect(@netapp_api).not_to receive(:request)
      @netapp_api.send_asup
    end
  end

  context 'mirror_group' do
    it 'is created' do
      response = double
      request_body = "{\"name\":\"demo_mirror_group\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:mirror_group_id).with('12345', 'demo_mirror_group').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/async-mirrors', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201], 'Failed to create mirror group')
      @netapp_api.create_mirror_group('10.0.0.1', name: 'demo_mirror_group')
    end

    it 'return false when storage system does not exist while create' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)
      expect(@netapp_api.create_mirror_group('10.0.0.1', name: 'demo_mirror_group')).to eq(false)
    end

    it 'return false when mirror group exists while create' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:mirror_group_id).with('12345', 'demo_mirror_group').and_return('111111')
      expect(@netapp_api.create_mirror_group('10.0.0.1', name: 'demo_mirror_group')).to eq(false)
    end

    it 'is deleted' do
      response = double
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:mirror_group_id).with('12345', 'demo_mirror_group').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/async-mirrors/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to delete mirror group')
      @netapp_api.delete_mirror_group('10.0.0.1', 'demo_mirror_group')
    end

    it 'return false when the Storage system does not exist while delete' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)
      expect(@netapp_api.delete_mirror_group('10.0.0.1', 'demo_mirror_group')).to eq(false)
    end

    it 'return false when the mirror group does not exist while delete' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:mirror_group_id).with('12345', 'demo_mirror_group').and_return(nil)
      expect(@netapp_api.delete_mirror_group('10.0.0.1', 'demo_mirror_group')).to eq(false)
    end
  end

  context 'mirror_group_id' do
    it 'returns id when group exist' do
      response = double(body: "[{\"label\":\"demo_mirror_group\",\"id\":\"111111\"}]")
      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/async-mirrors').and_return(response)
      expect(@netapp_api.send(:mirror_group_id, '12345', 'demo_mirror_group')).to eq('111111')
    end

    it 'returns nil when no mirror group exist' do
      response = double(body: '[]')
      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/async-mirrors').and_return(response)
      expect(@netapp_api.send(:mirror_group_id, '12345', 'demo_mirror_group')).to eq(nil)
    end

    it 'returns nil when the required mirror group does not exist' do
      response = double(body: "[{\"label\":\"demo_mirror_group_1\",\"id\":\"111111\"}]")
      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/async-mirrors').and_return(response)
      expect(@netapp_api.send(:mirror_group_id, '12345', 'demo_mirror_group')).to eq(nil)
    end
  end

  context 'volume_copy' do
    it 'is created' do
      response = double
      request_body = "{\"sourceId\":\"111\",\"targetId\":\"555\"}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems/12345/volume-copy-jobs', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], 'Failed to create volume copy pair')
      @netapp_api.create_volume_copy('10.0.0.1', sourceId: '111', targetId: '555')
    end

    it 'return false when storage system does not exist while create' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)
      expect(@netapp_api.create_volume_copy('10.0.0.1',  sourceId: '111', targetId: '555')).to eq(false)
    end

    it 'is deleted' do
      response = double
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_pair_id).with('12345', '111111').and_return('111111')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345/volume-copy-jobs/111111').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 204, [204], 'Failed to delete volume copy pair')
      @netapp_api.delete_volume_copy('10.0.0.1', '111111')
    end

    it 'return false when the Storage system does not exist while delete' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)
      expect(@netapp_api.delete_volume_copy('10.0.0.1', '111111')).to eq(false)
    end

    it 'return false when the volume copy does not exist while delete' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:volume_pair_id).with('12345', '111111').and_return(nil)
      expect(@netapp_api.delete_volume_copy('10.0.0.1', '111111')).to eq(false)
    end
  end

  context 'volume_pair_id' do
    it 'returns id when volume pair exist' do
      response = double(body: "[{\"id\":\"11111\"}]")
      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/volume-copy-jobs').and_return(response)
      expect(@netapp_api.send(:volume_pair_id, '12345', '11111')).to eq('11111')
    end

    it 'returns nil when no volume pair exist' do
      response = double(body: '[]')
      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/volume-copy-jobs').and_return(response)
      expect(@netapp_api.send(:volume_pair_id, '12345', '111111')).to eq(nil)
    end

    it 'returns nil when the required volume pair does not exist' do
      response = double(body: '[]')
      expect(@netapp_api).to receive(:request).with(:get, '/devmgr/v2/storage-systems/12345/volume-copy-jobs').and_return(response)
      expect(@netapp_api.send(:volume_pair_id, '12345', '111111')).to eq(nil)
    end
  end
end
