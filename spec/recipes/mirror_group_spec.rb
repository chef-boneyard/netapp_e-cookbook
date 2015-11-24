require_relative '../spec_helper'

describe 'netapp_e::mirror_group' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['mirror_group']) do |node|
      node.set['netapp']['mirror_group']['name'] = 'test'
      node.set['netapp']['storage_system_ip'] = '10.100.2.11'
      node.set['netapp']['mirror_group']['secondary_array_id'] = '347sjfksdfkanskfaskffdsfadffsa'
    end.converge(described_recipe)
  end

  it 'creates the mirror group through netapp_e_mirror_group' do
    expect(chef_run).to create_netapp_e_mirror_group('test')
  end

  it 'deletes the mirror group through netapp_e_mirror_group' do
    expect(chef_run).to delete_netapp_e_mirror_group('test')
  end
end
