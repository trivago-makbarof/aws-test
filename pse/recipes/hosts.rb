execute 'edit_hosts' do
  command 'echo "127.0.0.1 tsp-apd.tspdev" >> /etc/hosts ; echo "127.0.0.1 apd" >> /etc/hosts'
end

