include_attribute "pse"

pse_deploy 'test' do 
  user node['deployer']['user']
  group node['deployer']['group']
  deploy_root node['deploy']['root_path']
end 