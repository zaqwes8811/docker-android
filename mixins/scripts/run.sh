#!/bin/bash

function shuwdown(){
  echo "SIGTERM is received! Clean-up will be executed if needed!"
  process_id=$(pgrep -f "start device")
  kill ${process_id}
  sleep 10
  if [[ ${DEVICE_TYPE} == "geny_aws" ]]; then
    # Give time to execute tear_down method
    sleep 180
  fi
}

trap shuwdown SIGTERM

sudo gpasswd -a androidusr kvm
sudo chown androidusr:kvm /dev/kvm

SUPERVISORD_CONFIG_PATH="${APP_PATH}/mixins/configs/process"
if [[ ${DEVICE_TYPE} == "geny_"* ]]; then
  /usr/bin/supervisord --configuration ${SUPERVISORD_CONFIG_PATH}/supervisord-base.conf & \
  wait
elif [[ ${EMULATOR_HEADLESS} == true ]]; then
  /usr/bin/supervisord --configuration ${SUPERVISORD_CONFIG_PATH}/supervisord-port.conf & \
  /usr/bin/supervisord --configuration ${SUPERVISORD_CONFIG_PATH}/supervisord-base.conf & \
  wait
else
  /usr/bin/supervisord --configuration ${SUPERVISORD_CONFIG_PATH}/supervisord-screen.conf & \
  /usr/bin/supervisord --configuration ${SUPERVISORD_CONFIG_PATH}/supervisord-port.conf & \
  /usr/bin/supervisord --configuration ${SUPERVISORD_CONFIG_PATH}/supervisord-base.conf & \
  wait
fi
