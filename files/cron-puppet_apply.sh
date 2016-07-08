#!/bin/sh
## FILE MANAGED BY PUPPET ##
# puppet "agent" for masterless setups
# refresh the puppet config from the repo and apply

REPO=/etc/puppet
git --git-dir=${REPO}/.git --work-tree=${REPO} pull
puppet apply ${REPO}/manifests/site.pp