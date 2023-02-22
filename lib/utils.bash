#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/casey/just"
TOOL_NAME="just"
TOOL_TEST="just --version"

function fail() {
    echo -e "asdf-${TOOL_NAME}: ${*}"
    exit 1
}

# global vars
curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
    curl_opts=("${curl_opts[@]}" -H "Authorization: token ${GITHUB_API_TOKEN}")
fi

function sort_versions() {
    sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' \
        | LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

function list_github_tags() {
    git ls-remote --tags --refs "${GH_REPO}" \
        | grep -o 'refs/tags/.*' | cut -d/ -f3- \
        | sed 's/^v//'
}

function list_all_versions() {
    # currently all tags are valid releases, so this works
    list_github_tags
}

function get_platform() {
    local platform arch

    platform="$(uname -s)"
    arch="$(uname -m)"

    case "${platform}" in
        "Linux") platform_dl="unknown-linux-musl" ;;
        "*BSD") platform_dl="unknown-linux-musl" ;;
        "Darwin") platform_dl="apple-darwin" ;;
    esac
    case "${arch}" in
        "x86_64" | "amd64") arch_dl="x86_64" ;;
        "arm64" | "aarch64") arch_dl="aarch64" ;;
        "arm" | "armv7") arch_dl="armv7" ;;
    esac

    echo "${arch_dl}-${platform_dl}"
}

function download_release() {
    local version download_path url platform release_tar

    version="${1}"
    download_path="${2}"
    platform="$(get_platform)"
    release_tar="just-${version}-${platform}.tar.gz"

    url="${GH_REPO}/releases/download/${version}/${release_tar}"

    mkdir -p "${download_path}"

    echo "* Platform: ${platform}"
    echo "* Downloading ${TOOL_NAME} release ${version}..."
    if ! curl "${curl_opts[@]}" -o "${download_path}/${release_tar}" -C - "${url}"; then
        fail "Could not download ${url}"
    fi
}

function extract_release() {
    local version download_path platform release_tar

    version="${1}"
    download_path="${2}"
    platform="$(get_platform)"
    release_tar="just-${version}-${platform}.tar.gz"

    echo "* Extracting ${release_tar}..."
    if ! tar -xzf "${download_path}/${release_tar}" -C "${download_path}" just; then
        fail "Could not extract ${release_tar}"
    fi
    rm -f "${download_path}/${release_tar}"
}

function install_version() {
    local version install_path download_path tool_cmd

    version="${1}"
    install_path="${2%/bin}/bin"
    download_path="${3}"

    if ! (
        mkdir -p "${install_path}"

        mv -f "${download_path}/just" "${install_path}"

        tool_cmd="$(echo "${TOOL_TEST}" | cut -d' ' -f1)"
        if [[ ! -x "${install_path}/${tool_cmd}" ]]; then
            fail "Expected ${install_path}/${tool_cmd} to be executable."
        fi
        if ! "${install_path}/${tool_cmd}" --version; then
            fail "'${tool_cmd} --version' failed."
        fi

        echo "${TOOL_NAME} ${version} installation was successful!"
    ); then
        rm -rf "${install_path}"
        fail "An error occurred while installing ${TOOL_NAME} ${version}."
    fi
}
