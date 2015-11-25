require_relative '../spec_helper'

describe 'netapp_e::volume_copy' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['volume_copy']) do |node|
      node.set['netapp']['storage_system_ip'] = '10.100.2.11'
      node.set['netapp']['volume_copy']['name'] = 'test'
      node.set['netapp']['volume_copy']['source_id'] = 'e9f486b8-8634-4f58-9563-c57561633376'
      node.set['netapp']['volume_copy']['target_id'] = 'sewrkwejrwejr3472398423p432402'
    end.converge(described_recipe)
  end

  it 'creates the volume copy through netapp_e_volume_copy' do
    expect(chef_run).to create_netapp_e_volume_copy('test')
  end

  it 'deletes the volume copy through netapp_e_volume_copy' do
    expect(chef_run).to delete_netapp_e_volume_copy('test')
  end
end
