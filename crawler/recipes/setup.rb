include_recipe 'pse::setup'

appdata_path = '/appdata'
www_path = ::File.join(appdata_path, 'www')
release_directory = 'releases'

# Virtual hosts
cookbook_file "/etc/apache2/sites-available/010-crawler.conf" do
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/apache2/sites-available/010-apd.conf" do
  owner "root"
  group "root"
  mode "0644"
end

execute 'symlink_apd' do
  command 'ln -sf /etc/apache2/sites-available/010-apd.conf /etc/apache2/sites-enabled/010-apd.conf'
end

execute 'symlink_crawler' do
  command 'ln -sf /etc/apache2/sites-available/010-crawler.conf /etc/apache2/sites-enabled/010-crawler.conf'
end

# Cronjobs
cookbook_file "/etc/cron.d/crawler" do
  owner "root"
  group "root"
  mode "0644"
end

# Apps directories
Chef::Log.info %Q(Creating release directory for crawler)
directory "#{appdata_path}/crawler_data/#{release_directory}/dummy/web" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0755'
  recursive true
end

Chef::Log.info %Q(Creating release directory for apd)
directory "#{appdata_path}/apd_data/#{release_directory}" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0755'
  recursive true
end

Chef::Log.info %Q(Creating directory for crawler output)
directory "#{appdata_path}/crawler_data/live_output" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0755'
  recursive false
end


Chef::Log.info %Q(Creating directory for crawler logs)
directory "#{appdata_path}/crawler_data/live_logs" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0755'
  recursive false
end

FileUtils::ln_s "#{appdata_path}/crawler_data/#{release_directory}/dummy", ::File.join(appdata_path, "crawler_data/live_data")

`setfacl -R -m u:"www-data":rwX -m u:#{node['deployer']['user']}:rwX #{appdata_path}/crawler_data/live_logs`
`setfacl -dR -m u:"www-data":rwX -m u:#{node['deployer']['user']}:rwX #{appdata_path}/crawler_data/live_logs`

# Symlink overwriting seems to do some weird stuff, so remove it first...
FileUtils::ln_s ::File.join(www_path, 'crawler.trivago.trv'), ::File.join(appdata_path, "crawler_data/live_data/web")
FileUtils::ln_s ::File.join(www_path, 'tsp-apd.tspdev'), ::File.join(appdata_path, "apd_data/live_data/web")