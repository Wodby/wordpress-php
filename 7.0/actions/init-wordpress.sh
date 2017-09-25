#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

disclaimer="// Generated by Wodby (add before wp-settings.php include)."
wp_config="${WP_ROOT}/wp-config.php"

if [[ ! -f "${wp_config}" ]]; then
    cp -f "${WODBY_DIR_CONF}/wp-config.php" "${wp_config}"
elif [[ $( grep -ic "wodby.wp-config.php" "${wp_config}" ) -eq 0 ]]; then
    chmod 644 "${wp_config}"
    sed -i "/wp-settings.php/i \\
${disclaimer} \\
require_once '${WODBY_DIR_CONF}/wodby.wp-config.php';" "${wp_config}"
fi

# Symlink files dir
WP_FILES="${WP_ROOT}/wp-content/uploads"

if [[ -d "${WP_FILES}" ]]; then
    if [[ ! -L "${WP_FILES}" ]]; then
        if [[ "$(ls -A "${WP_FILES}")" ]]; then
            echo "Error: directory ${WP_FILES} exists and is not empty. The files directory can not be under version control or must be empty."
            exit 1
        # If dir is not symlink and empty, remove it and link.
        else
            rm -rf "${WP_FILES}"
            ln -sf "${WODBY_DIR_FILES}/public" "${WP_FILES}"
        fi
    fi
else
    ln -sf "${WODBY_DIR_FILES}/public" "${WP_FILES}"
fi
