require_relative 'spec_helper'
require_relative '../libraries/netapp_e_series_api'

describe 'netapp_e_series_api' do
  before do
    @netapp_api = NetApp::ESeries::Api.new('rw', 'rw', '127.0.0.1', true)
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
      @netapp_api_no_basic_auth = NetApp::ESeries::Api.new('rw', 'rw', '127.0.0.1', false)
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

  context 'storage_pool:' do
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
end
