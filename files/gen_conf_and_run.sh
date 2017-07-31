#!/usr/bin/env bash

set -e

srs_home=/opt/srs
dest_conf_path=${srs_home}/conf/flv_hooks.conf

function gen_conf () {
    cd /tmp/srs/config_generator

    cd gen_conf
    venv/bin/python ./gen_conf.py
    cd -

    cp output/srs_flv_hooks.conf ${dest_conf_path}
}

function run () {
    ${srs_home}/objs/nginx/sbin/nginx
    ${srs_home}/objs/srs -c ${dest_conf_path}
}

gen_conf
run