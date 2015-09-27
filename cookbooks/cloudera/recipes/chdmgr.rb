#chdmgr.rb

selinux_state "Disabled" do
  action :disabled
end

execute "Disable IPtables" do
  command "sudo /etc/init.d/iptables save && sudo /etc/init.d/iptables stop && sudo /sbin/chkconfig iptables off"
  creates "/tmp/something"
  action :run
end

directory "/opt/sources/" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

directory "/opt/sources/java" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

directory "/opt/sources/chd" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

rpm_package "jdk-7u71-linux-x64.rpm" do
	action :nothing
	source "/opt/sources/java/jdk-7u71-linux-x64.rpm"
end

bash "update-alternatives java" do
  action :nothing
  code <<-EOH
    /usr/sbin/alternatives --install "/usr/bin/java" "java" "/usr/java/latest/bin/java" 1
    /usr/sbin/alternatives --set java /usr/java/latest/bin/java

    /usr/sbin/alternatives --install "/usr/bin/javac" "javac" "/usr/java/latest/bin/javac" 1
    /usr/sbin/alternatives --set javac /usr/java/latest/bin/javac
  EOH
end

bash "Install-CHD" do 
	action :run
	cwd "/opt/sources/chd"
	code <<-EOH
		wget http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin
		chmod u+x cloudera-manager-installer.bin
	EOH
end
#sudo ./cloudera-manager-installer.bin

hostsfile_entry '192.168.56.30' do
  hostname  'chdmgr.local'
  aliases   ['chdmgr']
  unique    true
  action    :append
end
hostsfile_entry '192.168.56.31' do
  hostname  'chds1.local'
  aliases   ['chds1']
  unique    true
  action    :append
end
hostsfile_entry '192.168.56.32' do
  hostname  'chds2.local'
  aliases   ['chds2']
  unique    true
  action    :append
end


yum_package "ntp" do
  action :install
end

service "ntpd" do
  pattern "ntpd"
  action [:enable, :start]
end