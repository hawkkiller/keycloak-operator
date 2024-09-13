#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables (Modify these as needed)
CHART_NAME="keycloak-operator"
CHART_DIR="charts/$CHART_NAME"
GH_PAGES_BRANCH="gh-pages"
MAIN_BRANCH="main"
HELM_REPO_URL="https://your-github-username.github.io/your-repo-name/"  # Replace with your actual URL

# Function to check for uncommitted changes
check_uncommitted_changes() {
  if [[ -n $(git status --porcelain) ]]; then
    echo "Error: You have uncommitted changes. Please commit or stash them before running this script."
    exit 1
  fi
}

# Start of the script
echo "Starting the release process for $CHART_NAME..."

# Check for uncommitted changes
check_uncommitted_changes

# Ask for the new version
read -p "Enter the new release version (e.g., 1.2.3): " VERSION

# Validate version input (basic validation)
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format. Please use semantic versioning (e.g., 1.2.3)."
  exit 1
fi

# Update the chart version in Chart.yaml
echo "Updating Chart.yaml with version $VERSION..."
sed -i.bak "s/^version:.*/version: $VERSION/" "$CHART_DIR/Chart.yaml"
rm "$CHART_DIR/Chart.yaml.bak"

# Update the appVersion in Chart.yaml (if applicable)
# Uncomment the following lines if you want to update appVersion as well
# read -p "Enter the new appVersion (press Enter to skip): " APP_VERSION
# if [[ -n $APP_VERSION ]]; then
#   sed -i.bak "s/^appVersion:.*/appVersion: \"$APP_VERSION\"/" "$CHART_DIR/Chart.yaml"
#   rm "$CHART_DIR/Chart.yaml.bak"
# fi

# Package the Helm chart
echo "Packaging the Helm chart..."
helm package "$CHART_DIR" --destination .

# Switch to the GitHub Pages branch
echo "Switching to the $GH_PAGES_BRANCH branch..."
git checkout "$GH_PAGES_BRANCH"

# Update the Helm repo index
echo "Updating the Helm repo index..."
helm repo index . --url "$HELM_REPO_URL"

# Add changes to git
git add "$CHART_NAME-$VERSION.tgz" index.yaml

# Commit changes with the release version
echo "Committing the changes..."
git commit -m "Release $CHART_NAME-$VERSION"

# Push changes to the remote repository
echo "Pushing changes to $GH_PAGES_BRANCH..."
git push origin "$GH_PAGES_BRANCH"

# Switch back to the main branch
echo "Switching back to the $MAIN_BRANCH branch..."
git checkout "$MAIN_BRANCH"

# Merge changes from gh-pages back to main (optional)
# Uncomment the following lines if you want to merge the changes back to main
# echo "Merging changes from $GH_PAGES_BRANCH to $MAIN_BRANCH..."
# git merge "$GH_PAGES_BRANCH"
# git push origin "$MAIN_BRANCH"

echo "Release process for $CHART_NAME version $VERSION completed successfully."