execute 'edit_hosts' do
  command 'echo "127.0.0.1 tsp-apd.tspdev" >> /etc/hosts'
end

cookbook_file "/etc/apache2/sites-available/010-crawler.conf" do
  owner "root"
  group "root"
  mode "0644"
end 

