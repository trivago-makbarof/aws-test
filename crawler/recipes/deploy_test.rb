include_recipe "pse"

Chef::Log.info %Q(Deploying application "#{node['deploy']['root_path']}")

pse_deploy 'test' do 
  user node['deploy']['root_path']
  group node['deployer']['group']
  deploy_root node['deploy']['root_path']
end 