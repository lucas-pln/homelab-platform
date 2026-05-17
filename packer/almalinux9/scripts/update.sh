#!/bin/bash
set -euo pipefail


echo '[Provision] Updating packages'

dnf upgrade -y

echo '[Provision] Packages update complete'