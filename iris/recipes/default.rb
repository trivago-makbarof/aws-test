execute 'apache_configtest' do
  command 'echo "127.0.0.1 tsp-apd.tspdev" >> /etc/hosts'
end
