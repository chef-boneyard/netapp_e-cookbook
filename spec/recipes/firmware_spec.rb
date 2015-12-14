require_relative '../spec_helper'

describe 'netapp_e::firmware' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['firmware']) do |node|
      node.set['netapp']['firmware']['cwf_file'] = 'test_file'
      node.set['netapp']['firmware']['nvsram_file'] = 'test_nvsram_file'
      node.set['netapp']['firmware']['stage_firmware'] = false
      node.set['netapp']['firmware']['skip_mel_check'] = false
      node.set['netapp']['storage_system_ip'] = '10.100.2.11'
    end.converge(described_recipe)
  end

  it 'upgrades the firmware' do
    expect(chef_run).to upgrade_netapp_e_firmware('10.100.2.11')
  end
end
