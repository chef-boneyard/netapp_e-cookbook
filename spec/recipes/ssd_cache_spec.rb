require_relative '../spec_helper'

describe 'netapp_e::ssd_cache' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['ssd_cache']) do |node|
      node.set['netapp']['ssd_cache']['drive_refs'] = ['111111fsfdsa']
      node.set['netapp']['storage_system_ip'] = '10.100.2.11'
    end.converge(described_recipe)
  end

  it 'creates the ssd cache through netapp_e_ssd_cache' do
    expect(chef_run).to create_netapp_e_ssd_cache(chef_run.node['netapp']['storage_system_ip'])
  end

  it 'deletes the ssd cache through netapp_e_ssd_cache' do
    expect(chef_run).to delete_netapp_e_ssd_cache(chef_run.node['netapp']['storage_system_ip'])
  end

  it 'adds the drives into ssd/flash cache therough netapp_e_ssd_cache' do
    expect(chef_run).to update_netapp_e_ssd_cache(chef_run.node['netapp']['storage_system_ip'])
  end

  it 'resumes the ssd/flash cache through netapp_e_ssd_cache' do
    expect(chef_run).to resume_netapp_e_ssd_cache(chef_run.node['netapp']['storage_system_ip'])
  end

  it 'suspends the ssd/flash cache through netapp_e_ssd_cache' do
    expect(chef_run).to suspend_netapp_e_ssd_cache(chef_run.node['netapp']['storage_system_ip'])
  end
end
