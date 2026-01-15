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
		if [[ -f "./Server/HytaleServer.jar" ]]; then
			rm -rf ./Server/*
			$HYTALE_DOWNLOADER -patchline "$HYTALE_PATCHLINE" -download-path HytaleServer.zip
		elif [[ -f "./HytaleMount/Server/HytaleServer.jar" ]]; then
			rm -rf ./HytaleMount/Server/*
			$HYTALE_DOWNLOADER -patchline "$HYTALE_PATCHLINE" -download-path HytaleServer.zip
		else
			$HYTALE_DOWNLOADER -patchline "$HYTALE_PATCHLINE" -download-path HytaleServer.zip
		fi
	fi

	if [[ -f "HytaleServer.zip" ]]; then
		unzip -o HytaleServer.zip -d .
		rm -f HytaleServer.zip
	fi
elif [[ -f "HytaleMount/HytaleServer.zip" ]]; then
	unzip -o HytaleMount/HytaleServer.zip -d .
elif [[ -f "HytaleMount/Assets.zip" ]]; then
	ln -s -f HytaleMount/Assets.zip Assets.zip
elif [[ -f "Server/Assets.zip" ]]; then
	ln -s -f Server/Assets.zip Assets.zip
elif [[ -f "HytaleServer.zip" ]]; then
	unzip -o HytaleServer.zip -d .
fi

# Download the latest hytale-sourcequery plugin if enabled
if [ "${INSTALL_SOURCEQUERY_PLUGIN}" == "1" ]; then
	mkdir -p mods
	echo -e "Downloading latest hytale-sourcequery plugin..."
	LATEST_URL=$(curl -sSL https://api.github.com/repos/physgun-com/hytale-sourcequery/releases/latest \
		| grep -oP '"browser_download_url":\s*"\K[^"]+\.jar' || true)
	if [[ -n "$LATEST_URL" ]]; then
		curl -sSL -o mods/hytale-sourcequery.jar "$LATEST_URL"
		echo -e "Successfully downloaded hytale-sourcequery plugin to mods folder."
	else
		echo -e "Warning: Could not find hytale-sourcequery plugin download URL."
	fi
fi

if [[ -f config.json && -n "$HYTALE_MAX_VIEW_RADIUS" ]]; then
	jq ".MaxViewRadius = $HYTALE_MAX_VIEW_RADIUS" config.json > config.tmp.json && mv config.tmp.json config.json
fi

/java.sh $@
