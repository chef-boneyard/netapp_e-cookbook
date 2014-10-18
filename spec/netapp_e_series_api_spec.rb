require_relative 'spec_helper'
require_relative '../libraries/netapp_e_series_api'

describe 'netapp_e_series_api' do
  before do
    @netapp_api = NetApp::ESeries::Api.new('rw', 'rw', '127.0.0.1', true)
  end

  context 'login' do
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

  context 'logout' do
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

  context 'status' do
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

  context 'request and web proxy headers' do
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

  context 'storage_system' do
    it 'is created when it does not exist' do
      response = double
      request_body = "{\"controllerAddresses\":[\"10.0.0.1\"]}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)
      expect(@netapp_api).to receive(:request).with(:post, '/devmgr/v2/storage-systems', request_body).and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 201, [201, 200], 'Storage Creation Failed')

      @netapp_api.create_storage_system(controllerAddresses: ['10.0.0.1'])
    end

    it 'return false when storage system exists' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')

      expect(@netapp_api.create_storage_system(controllerAddresses: ['10.0.0.1'])).to eq(false)
    end

    it 'is deleted when the storage system exists' do
      response = double
      request_body = "{\"controllerAddresses\":[\"10.0.0.1\"]}"

      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return('12345')
      expect(@netapp_api).to receive(:request).with(:delete, '/devmgr/v2/storage-systems/12345').and_return(response)
      expect(@netapp_api).to receive(:status).with(response, 200, [200], "Storage Deletion Failed")

      @netapp_api.delete_storage_system('10.0.0.1')
    end

    it 'return false if the storage system does not exist' do
      expect(@netapp_api).to receive(:storage_system_id).with('10.0.0.1').and_return(nil)

      expect(@netapp_api.delete_storage_system('10.0.0.1')).to eq(false)
    end
  end
end
