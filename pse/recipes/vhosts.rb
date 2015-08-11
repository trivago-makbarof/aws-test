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

execute 'symlink_apdr' do
  command 'ln -s /etc/apache2/sites-available/010-apd.conf /etc/apache2/sites-enabled/010-apd.conf'
end

execute 'symlink_crawler' do
  command 'ln -s /etc/apache2/sites-available/010-crawler.conf /etc/apache2/sites-enabled/010-crawler.conf'
end
