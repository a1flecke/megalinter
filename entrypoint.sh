#!/usr/bin/env bash

PYTHONPATH=$PYTHONPATH:$(pwd)
export PYTHONPATH

# Manage newest git versions (related to CVE https://github.blog/2022-04-12-git-security-vulnerability-announced/)
if [ -z ${GITHUB_WORKSPACE+x} ]; then
  echo "Setting git safe.directory default: /github/workspace ..."
  git config --global --add safe.directory /github/workspace
else
  echo "Setting git safe.directory GITHUB_WORKSPACE: $GITHUB_WORKSPACE ..."
  git config --global --add safe.directory "$GITHUB_WORKSPACE"
fi
echo "Setting git safe.directory to /tmp/lint ..."
git config --global --add safe.directory /tmp/lint

if [ "${UPGRADE_LINTERS_VERSION}" == "true" ]; then
  echo "UPGRADING LINTER VERSION"
  # Run only get_linter_version test methods
  pytest -v --durations=0 -k _get_linter_version megalinter/
  # Run only get_linter_help test methods
  pytest -v --durations=0 -k _get_linter_help megalinter/
  # Reinstall mkdocs-material because of broken dependency
  pip3 install --ignore-installed mkdocs-material
  cd /tmp/lint || exit 1
  chmod +x build.sh
  bash build.sh --doc
  exit $?
fi

if [ "${TEST_CASE_RUN}" == "true" ]; then
  # Run test cases with pytest
  echo "RUNNING TEST CASES"
  if [ -z "${TEST_KEYWORDS}" ]; then
    pytest -v --timeout=60 --durations=0 --cov=megalinter --cov-report=xml megalinter/
  else
    pytest -v --timeout=60 --durations=0 -k "${TEST_KEYWORDS}" megalinter/
  fi
  PYTEST_STATUS=$?
  echo Pytest exited $PYTEST_STATUS
  # Manage return code
  if [ $PYTEST_STATUS -eq 0 ]; then
    echo "Successfully executed Pytest"
  else
    echo "Error(s) found by Pytest"
    exit 1
  fi
  # Upload to codecov.io
  bash <(curl -s https://codecov.io/bash)

else
  # Normal run
  LOG_LEVEL="${LOG_LEVEL:-INFO}" # Default log level (VERBOSE, DEBUG, TRACE)
  if [[ ${LOG_LEVEL} == "DEBUG" ]]; then
    printenv
  fi
  python -m megalinter.run
fi
