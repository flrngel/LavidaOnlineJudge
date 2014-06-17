#
# Cookbook Name:: mariadb
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

remote_file "#{node['loj']['path']}/setup/src/mariadb-#{node['mariadb']['version']}.tar.gz" do
	source "http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/mariadb-#{node['mariadb']['version']}/source/mariadb-#{node['mariadb']['version']}.tar.gz"
end

bash "mariradb_install" do
	user "#{node['loj']['user']}"
	cwd "#{node['loj']['path']}/setup/src"
	code <<-EOH
		tar xvzf mariadb-#{node['mariadb']['version']}.tar.gz
		cd mariadb-#{node['mariadb']['version']}
		mkdir build
		cd build
		cmake .. \
		-DBUILD_CONFIG=mysql_release \
		-DWITH_READLINE=1 \
		-DWITH_SSL=bundled \
		-DWITH_ZLIB=system \
		-DDEFAULT_CHARSET=utf8 \
		-DDEFAULT_COLLATION=utf8_general_ci \
		-DDEFAULT_ENGINE=INNOBASE \
		-DENABLED_LOCAL_INFILE=1 \
		-DWITH_EXTRA_CHARSETS=all \
		-DWITH_ARIA_STORAGE_ENGINE=1 \
		-DWITH_XTRADB_STORAGE_ENGINE=0 \
		-DWITH_ARCHIVE_STORAGE_ENGINE=0 \
		-DWITH_INNOBASE_STORAGE_ENGINE=1 \
		-DWITH_PARTITION_STORAGE_ENGINE=0 \
		-DWITH_BLACKHOLE_STORAGE_ENGINE=0 \
		-DWITH_FEDERATEDX_STORAGE_ENGINE=0 \
		-DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
		-DCMAKE_INSTALL_PREFIX=$INSTALL_PATH/packages/mariadb \
		-DMYSQL_DATADIR=$INSTALL_PATH/data/mariadb/data
		make && make install

		ln -s #{node['loj']['path']}/packages/mariadb/lib #{node['loj']['path']}/packages/mariadb/lib64
		sudo bash -c "echo \"#{node['loj']['path']}/packages/mariadb/lib\" > /etc/ld.so.conf.d/mysql.conf"

		sudo groupadd -g 27 -o -r mysql
		useradd -M -g mysql -o -r -d #{node['loj']['path']}/data/mariadb/data -s /bin/false -c "MariaDB" -u 27 mysql

		sudo cp #{node['loj']['path']}/packages/mariadb/support-files/mysql.server /etc/init.d/mysqld
		sudo update-rc.d mysqld defaults

		sudo ln -s /etc/my.cnf #{node['loj']['path']}/config/my.cnf
	EOH
end