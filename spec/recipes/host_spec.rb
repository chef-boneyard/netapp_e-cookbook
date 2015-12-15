require_relative '../spec_helper'

describe 'netapp_e::host' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['host']) do |node|
      node.set['netapp']['host']['name'] = 'test'
      node.set['netapp']['storage_system_ip'] = '127.1.1.1'
    end.converge(described_recipe)
  end

  it 'creates the host through netapp_e_host' do
    expect(chef_run).to create_netapp_e_host(chef_run.node['netapp']['host']['name'])
  end

  it 'deletes the host through netapp_e_host' do
    expect(chef_run).to delete_netapp_e_host(chef_run.node['netapp']['host']['name'])
  end
end
