require_relative '../libraries/helper.rb'
require_relative '../libraries/netapp_e_series_api'

class NetAppHelper
  attr_accessor :node
  include NetAppEHelper

  def initialize
    @node = {}
  end
end

describe 'netapp e series cookbook helper method' do
  before do
    @netapp_e_helper = NetAppHelper.new
  end

  context 'netapp_api_create:' do
    it 'when timeout is set' do
      @netapp_e_helper.node['netapp'] = { 'user' => 'rw', 'password' => 'rw', 'basic_auth' =>  true, 'api' => { 'timeout' => 100 }, 'asup' => true }

      params = {  user: 'rw', password: 'rw',
                  url: 'http://10.0.0.1:8080', basic_auth: true,
                  asup: true, timeout: 100
                }
      expect(@netapp_e_helper).to receive(:validate_node_attributes)
      expect(@netapp_e_helper).to receive(:url).and_return('http://10.0.0.1:8080')
      expect(NetApp::ESeries::Api).to receive(:new).with(params)

      @netapp_e_helper.netapp_api_create
    end

    it 'when timeout is not set' do
      @netapp_e_helper.node['netapp'] = { 'user' => 'rw', 'password' => 'rw', 'basic_auth' =>  true, 'asup' => true }
      params = {  user: 'rw', password: 'rw',
                  url: 'http://10.0.0.1:8080', basic_auth: true,
                  asup: true
                }
      expect(@netapp_e_helper).to receive(:validate_node_attributes)
      expect(@netapp_e_helper).to receive(:url).and_return('http://10.0.0.1:8080')
      expect(NetApp::ESeries::Api).to receive(:new).with(params)

      @netapp_e_helper.netapp_api_create
    end
  end

  context 'url:' do
    it 'when https and port is set' do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'fqdn' =>  '10.0.0.1', 'port' => '9000' }

      expect(@netapp_e_helper.url).to eq('https://10.0.0.1:9000')
    end

    it 'when https and port is set' do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'fqdn' =>  '10.0.0.1' }

      expect(@netapp_e_helper.url).to eq('https://10.0.0.1:8443')
    end

    it 'when http and port is set' do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'fqdn' =>  '10.0.0.1', 'port' => '9000' }

      expect(@netapp_e_helper.url).to eq('http://10.0.0.1:9000')
    end

    it 'when http and port is set' do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'fqdn' =>  '10.0.0.1' }

      expect(@netapp_e_helper.url).to eq('http://10.0.0.1:8080')
    end
  end

  context 'validate_node_attributes:' do
    it "exits when default['netapp']['https'] is not set" do
      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['https'] set incorrectly" do
      @netapp_e_helper.node['netapp'] = { 'https' => nil }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['user'] is not set" do
      @netapp_e_helper.node['netapp'] = { 'https' => true }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['user'] is set incorrectly" do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'user' => 1 }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['password'] is not set" do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'user' => 'rw' }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['password'] is set incorrectly" do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'user' => 'rw', 'password' => 1 }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['fqdn'] is not set" do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw' }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['fqdn'] is set incorrectly" do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 1 }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['basic_auth'] is not set" do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com' }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['basic_auth'] is set incorrectly" do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => 'true' }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['asup'] is not set" do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com' }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it "exits when default['netapp']['asup'] is set incorrectly" do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => true, 'asup' => 'true' }

      expect { @netapp_e_helper.validate_node_attributes }.to raise_error
    end

    it 'succeeds when the attributes are set correctly case-1' do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => true, 'asup' => true }

      @netapp_e_helper.validate_node_attributes
    end

    it 'succeeds when the attributes are set correctly case-2' do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => true, 'asup' => true }

      @netapp_e_helper.validate_node_attributes
    end

    it 'succeeds when the attributes are set correctly case-3' do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => false, 'asup' => true }

      @netapp_e_helper.validate_node_attributes
    end

    it 'succeeds when the attributes are set correctly case-4' do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => false, 'asup' => true }

      @netapp_e_helper.validate_node_attributes
    end

    it 'succeeds when the attributes are set correctly case-5' do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => true, 'asup' => false }

      @netapp_e_helper.validate_node_attributes
    end

    it 'succeeds when the attributes are set correctly case-6' do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => true, 'asup' => false }

      @netapp_e_helper.validate_node_attributes
    end

    it 'succeeds when the attributes are set correctly case-7' do
      @netapp_e_helper.node['netapp'] = { 'https' => true, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => false, 'asup' => false }

      @netapp_e_helper.validate_node_attributes
    end

    it 'succeeds when the attributes are set correctly case-8' do
      @netapp_e_helper.node['netapp'] = { 'https' => false, 'user' => 'rw', 'password' => 'rw', 'fqdn' => 'example.com', 'basic_auth' => false, 'asup' => false }

      @netapp_e_helper.validate_node_attributes
    end
  end
end
