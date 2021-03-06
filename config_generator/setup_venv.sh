#!/usr/bin/env bash

set -e

function prepare_virtualenv () {
    pip install virtualenv
}

function pip_install () {
    venv_dir=$1
    requirement_txt=$2

    if [ ! -d ${venv_dir} ]; then
        virtualenv -p $(which python) --always-copy ${venv_dir}
    fi

    source ${venv_dir}/bin/activate

    pip install -r ${requirement_txt}

    deactivate
}

prepare_virtualenv
pip_install venv requirements.txt
