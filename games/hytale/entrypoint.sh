#!/bin/bash
set -e

cd /home/container

# If HYTALE_SERVER_SESSION_TOKEN isn't set, assume the user will log in themselves, rather than a host's GSP
if [[ -z "$HYTALE_SERVER_SESSION_TOKEN" ]]; then
    if [ "$(uname -m)" = "aarch64" ]; then
		HYTALE_DOWNLOADER="qemu-x86_64-static ./hytale-downloader/hytale-downloader-linux"
	else
		HYTALE_DOWNLOADER="./hytale-downloader/hytale-downloader-linux"
	fi

	# Default to downloading (unless we find matching version)
	NEEDS_DOWNLOAD=true

	if [[ -f "./Server/HytaleServer.jar" || -f "./HytaleMount/Server/HytaleServer.jar" ]]; then
		CURRENT_VERSION=$(java -jar ./Server/HytaleServer.jar --version | awk '{print $2}' | sed 's/^v//')
		LATEST_VERSION=$($HYTALE_DOWNLOADER -print-version)
		
		if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
			NEEDS_DOWNLOAD=true
		else
			NEEDS_DOWNLOAD=false
		fi
	else
		NEEDS_DOWNLOAD=true
	fi

	if [[ "$NEEDS_DOWNLOAD" = true ]]; then
		$HYTALE_DOWNLOADER -patchline "$HYTALE_PATCHLINE" -download-path HytaleServer.zip
	fi

	if [[ -f "HytaleServer.zip" ]]; then
		unzip -o HytaleServer.zip -d .
		rm -f HytaleServer.zip
	fi
elif [[ -f "HytaleServer.zip" ]]; then
	unzip -o HytaleServer.zip -d .
	rm -f HytaleServer.zip
elif [[ -f "HytaleMount/HytaleServer.zip" ]]; then
	unzip -o HytaleMount/HytaleServer.zip -d .
	rm -f HytaleMount/HytaleServer.zip
fi

/java.sh $@
