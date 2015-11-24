require_relative '../spec_helper'

describe 'netapp_e::consistency_group' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['consistency_group']) do |node|
      node.set['netapp']['consistency_group']['name'] = 'test'
      node.set['netapp']['storage_system_ip'] = '10.100.2.11'
    end.converge(described_recipe)
  end

  it 'creates the consistency group through netapp_e_consistency_group' do
    expect(chef_run).to create_netapp_e_consistency_group('test')
  end

  it 'deletes the consistency group through netapp_e_consistency_group' do
    expect(chef_run).to delete_netapp_e_consistency_group('test')
  end
end
