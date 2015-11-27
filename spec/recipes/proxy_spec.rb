require 'chefspec'

describe 'netapp_e::proxy' do
  let(:chef_run) do
    ChefSpec::SoloRunner.converge(described_recipe)
  end

  # it 'creates a template file' do
  #   expect(:chef_run).to create_template('/tmp/installer.properties')
  # end

  it 'creates a remote_file with the default action' do
    expect(chef_run).to create_remote_file('web_proxy')
  end
end
