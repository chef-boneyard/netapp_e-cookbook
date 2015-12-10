require_relative '../spec_helper'

describe 'netapp_e::consistency_group' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['consistency_group']) do |node|
      node.set['netapp']['consistency_group']['name'] = 'test'
      node.set['netapp']['storage_system_ip'] = '192.168.1.1'
      node.set['netapp']['consistency_group']['full_warn_threshold_percent'] = 75
      node.set['netapp']['consistency_group']['auto_delete_threshold'] = 32
      node.set['netapp']['consistency_group']['repository_full_policy'] = 'purgepit'
      node.set['netapp']['consistency_group']['rollback_priority'] = 'highest'
    end.converge(described_recipe)
  end

  it 'creates the consistency group through netapp_e_consistency_group' do
    expect(chef_run).to create_netapp_e_consistency_group('test')
  end

  it 'deletes the consistency group through netapp_e_consistency_group' do
    expect(chef_run).to delete_netapp_e_consistency_group('test')
  end
end
