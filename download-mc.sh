#!/bin/sh

mc_manifest=https://launchermeta.mojang.com/mc/game/version_manifest.json 
version=$1

if ! command -v jq > /dev/null
then
	printf "Missing dependencies: jq"
	exit
fi

if [ -z $version ]
then
	printf "Please provide version number or 'latest'"
	exit
fi

mc_manifest_json=$(wget -qO - $mc_manifest)

if [ $version = 'latest' ]
then
	version=$(echo $mc_manifest_json | jq '.latest.release' | sed 's/"//g')
fi

for i in $(echo $mc_manifest_json | jq '.versions | keys | .[]') 
do
	if [ $version = "$(echo $mc_manifest_json | jq ".versions[$i].id" | sed 's/"//g')" ]
	then
		version_url=$(echo $mc_manifest_json | jq ".versions[$i].url")
		break
	fi
done

version_url_http=$(echo $version_url | sed 's/https/http/;s/"//g')
download_url=$(wget -qO - $version_url_http | jq .downloads.server.url | sed 's/"//g')
printf "Downloading version $version\n\n"
wget $download_url -O server-$version.jar
exit
