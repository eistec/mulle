#!/bin/bash

# exit on error
set -e

echo "Mulle Programmer v0.60 serial number flasher"

TEMPLATE_CONF="$(dirname $0)/mulle_programmer.conf.template"
FTDI_EEPROM="ftdi_eeprom"

function cleanup {
    echo "Removing temporary file: '${MYCONFTMP}'"
    rm -f "${MYCONFTMP}"
}
MYCONFTMP="$(mktemp)"
trap cleanup EXIT

if ! [ -f "${MYCONFTMP}" ]; then
    echo "Unable to create a temporary file" 1>&2
    exit 2
fi


echo "Enter the desired serial number:"
unset MYSERIAL
read MYSERIAL
if [ -z "${MYSERIAL}" ]; then
    echo "Missing serial number input" 1>&2
    exit 1
fi

echo "Writing serial '${MYSERIAL}'"
cat "${TEMPLATE_CONF}" > "${MYCONFTMP}"
echo "serial=\"${MYSERIAL}\"" >> "${MYCONFTMP}"
echo "${FTDI_EEPROM}" --flash-eeprom "${MYCONFTMP}"
"${FTDI_EEPROM}" --flash-eeprom "${MYCONFTMP}"
