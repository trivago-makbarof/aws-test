include_recipe "pse"

pse_deploy 'test' do 
  user node['deployer']['user']
  group node['deployer']['group']
end 