#!/usr/bin/env bash
set -u -e -o pipefail

# Script that runs all unit tests of the `angular/components` repository. The script also
# sets up the test blocklist from `tools/components-repo-ci`.

# Path to the Angular project.
angular_dir=$(pwd)

# Switch into the temporary directory where the `angular/components`
# repository has been cloned into.
cd ${COMPONENTS_REPO_TMP_DIR}

# Copy the test blocklist into the `angular/components` repository. The unit tests will
# automatically pick up the blocklist and disable the specified tests.
cp ${angular_dir}/tools/components-repo-ci/test-blocklist.ts ${COMPONENTS_REPO_TMP_DIR}/test/

# Create a symlink for the Bazel binary installed through NPM, as running through Yarn introduces OOM errors.
./scripts/circleci/setup_bazel_binary.sh

# Now actually run the tests. The dev-app and all its subpackages are excluded as they fail
# to compile due to limitations in Ivy's type checker (see FW-1352 and FW-1433)
bazel test --build_tag_filters=-docs-package,-e2e,-browser:firefox-local --test_tag_filters=-e2e,-browser:firefox-local --config=ivy -- src/... -src/dev-app/...
