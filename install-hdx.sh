#!/bin/bash

[[ $EUID -ne 0 ]] && echo "This script must be run w/ su permissions" && exit 1

file="$@"
[ -z "${file}" ] && printf "Please define a file.\nUsage:\n./install-hdx.sh <file-name>\n" && exit 1
[ ! -f "${file}" ] && printf "File does not exist: %s\n" "$file" && exit 1

nopath=$(basename "$file")
noext="${nopath%.zip}"

rm -rf "/tmp/${noext}"
printf "INFO: Unzipping %s to /tmp...\n" "$noext"
unzip "${file}" -d  /tmp

cd "/tmp/${noext}"
printf "INFO: Unarchiving .deb and its contents...\n" "$noext"
ar -xv x86_64/*.deb
tar -xvf control.tar.gz
tar -xvf data.tar.xz

[ ! -d /usr/local/bin ] && printf "INFO: Creating \"/usr/local/bin\" since it doesn't exist yet...\n" && mkdir /usr/local/bin
printf "INFO: Moving bin files from deb...\n"
mv ./usr/local/bin/* /usr/local/bin/
printf "INFO: Running postinst from deb...\n"
./postinst configure

printf "INFO: Removing tmp files...\n"
rm -rf "/tmp/${noext}"

printf "INFO: Done!!!\n"

printf "NOTE: Don't forget to set \"AllowAudioInput=True\" under \"[WFClient]\" inside your \"~/.ICAClient/wfclient.ini\"\n"
exit 0
