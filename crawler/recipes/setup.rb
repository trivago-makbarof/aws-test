include_recipe 'pse::setup'

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
directory "/appdata/crawler_data/releases" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0755'
  recursive false
end

directory "/appdata/apd_data/releases" do
  owner     node['deployer']['user']
  group     node['deployer']['group']
  mode      '0755'
  recursive false
end