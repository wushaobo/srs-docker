#!/usr/bin/env bash

set -e

srs_home=/opt/srs
dest_conf_path=${srs_home}/conf/hls_hooks.conf

function gen_conf () {
    cd /tmp/srs/config_generator

    venv/bin/env2conf -i templates -o output

    cp output/srs_hls_hooks.conf ${dest_conf_path}
}

function run () {
    cd ${srs_home}
    ./objs/nginx/sbin/nginx
    ./objs/srs -c ${dest_conf_path}
}

gen_conf
run
