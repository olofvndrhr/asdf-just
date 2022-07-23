#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/casey/just"
TOOL_NAME="just"
TOOL_TEST="just --version"

fail() {
    echo -e "asdf-${TOOL_NAME}: ${*}"
    exit 1
}

# global vars
curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
    curl_opts=("${curl_opts[@]}" -H "Authorization: token ${GITHUB_API_TOKEN}")
fi

sort_versions() {
    sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' \
        | LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
    git ls-remote --tags --refs "$GH_REPO" \
        | grep -o 'refs/tags/.*' | cut -d/ -f3- \
        | sed 's/^v//'
}

list_all_versions() {
    # currently all tags are valid releases, so this works
    list_github_tags
}

get_JUST_PLATFORM() {
    local JUST_PLATFORM arch

    JUST_PLATFORM="$(uname -s)"
    arch="$(uname -m)"

    case "${JUST_PLATFORM}" in
        "Linux") JUST_PLATFORM_dl="unknown-linux-musl" ;;
        "*BSD") JUST_PLATFORM_dl="unknown-linux-musl" ;;
        "Darwin") JUST_PLATFORM_dl="apple-darwin" ;;
    esac
    case "${arch}" in
        "x86_64" | "amd64") arch_dl="x86_64" ;;
        "arm64" | "aarch64") arch_dl="aarch64" ;;
        "arm" | "armv7") arch_dl="armv7" ;;
    esac

    echo "${arch_dl}-${JUST_PLATFORM_dl}"
}

download_release() {
    local version download_path url

    version="${1:-${ASDF_INSTALL_VERSION}}"
    download_path="${2:-${ASDF_DOWNLOAD_PATH}}"

    url="${GH_REPO}/releases/download/${version}/${JUST_RELEASE_TAR}"

    mkdir -p "${download_path}"

    echo "* Downloading ${TOOL_NAME} release ${version}..."
    if ! curl "${curl_opts[@]}" -o "${download_path}/${JUST_RELEASE_TAR}" -C - "${url}"; then
        fail "Could not download ${url}"
    fi
}

extract_release() {
    local version download_path

    version="${1:-${ASDF_INSTALL_VERSION}}"
    download_path="${2:-${ASDF_DOWNLOAD_PATH}}"

    if ! tar -xzf "${download_path}/${JUST_RELEASE_TAR}" -C "${download_path}" just; then
        fail "Could not extract ${JUST_RELEASE_TAR}"
    fi
    rm "${download_path}/${JUST_RELEASE_TAR}"
}

install_version() {
    local install_type version install_path download_path tool_cmd

    install_type="${1:-${ASDF_INSTALL_TYPE}}"
    version="${2:-${ASDF_INSTALL_VERSION}}"
    install_path="${3:-${ASDF_INSTALL_PATH}}"
    download_path="${4:-${ASDF_DOWNLOAD_PATH}}"

    if [ "${install_type}" != "version" ]; then
        fail "asdf-${TOOL_NAME} supports release installs only"
    fi

    if ! (
        mkdir -p "${install_path}"

        mv "${download_path}/just" "${install_path}"

        tool_cmd="$(echo "${TOOL_TEST}" | cut -d' ' -f1)"
        if [[ ! -x "${install_path}/${tool_cmd}" ]]; then
            fail "Expected ${install_path}/${tool_cmd} to be executable."
        fi
        if ! "${tool_cmd}" --version; then
            fail "'${tool_cmd} --version' failed."
        fi

        echo "${TOOL_NAME} ${version} installation was successful!"
    ); then
        rm -rf "${install_path}"
        fail "An error occurred while installing ${TOOL_NAME} ${version}."
    fi
}

# get some variables
JUST_PLATFORM="$(get_JUST_PLATFORM)"
JUST_RELEASE_TAR="just-${ASDF_INSTALL_VERSION}-${JUST_PLATFORM}.tar.gz"
