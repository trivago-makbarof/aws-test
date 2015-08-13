include_recipe "pse"


t = Time.now
version = t.strftime("%Y%m%d%H%M%S")

pse_deploy 'crawler' do 
  user node['deployer']['user']
  group node['deployer']['group']
  deploy_root['deploy']['root_path']
  version version
  action :prepare_release
end


# Can we share the way we build the path between this recipe and the provider in pse_deploy
release_path = ::File.join(deploy_root['deploy']['root_path'], "crawler_data/releases", version)

output_path = ::File.join(deploy_root['deploy']['root_path'], "crawler_data/live_output")
output_symlink = ::File.join(release_path, "output")

logs_path = ::File.join(deploy_root['deploy']['root_path'], "crawler_data/live_logs")
logs_symlink = ::File.join(release_path, "app/logs")

ruby_block "output_symlink" do
  block do
  	Chef::Log.info %Q(Updating Symlink for the output directory")
    # Symlink overwriting seems to do some weird stuff, so remove it first...
    FileUtils::rm_rf output_symlink
    FileUtils::ln_s output_path, output_symlink

    FileUtils::rm_rf logs_symlink
    FileUtils::ln_s logs_path, logs_symlink

    Chef::Log.info %Q(Creating cache dir if it doesn't exist and using setfacl for permission)
    cache_dir = ::File.join(release_path, "app/cache")

    Chef::Log.info %Q(Creating directory for crawler logs)
    directory "#{release_path}/app/cache" do
      owner     node['deployer']['user']
      group     node['deployer']['group']
      mode      '0755'
      recursive false
    end

    `setfacl -R -m u:"www-data":rwX -m u:#{node['deployer']['user']}:rwX #{release_path}/app/cache`
    `setfacl -dR -m u:"www-data":rwX -m u:#{node['deployer']['user']}:rwX #{release_path}/app/cache`
  end
end


pse_deploy 'crawler' do 
  user node['deployer']['user']
  group node['deployer']['group']
  deploy_root['deploy']['root_path']
  version version
  :deploy
end