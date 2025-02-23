#!/bin/bash

# Exit on any error
set -e

# First, stash any changes that aren't part of the commit
git stash push -m "pre-build-stash" --keep-index

# Try to build the application
if ! ./gradlew clean build; then
    echo "❌ Build failed! Aborting version bump."
    git stash pop
    exit 1
fi

# Restore stashed changes
git stash pop

# Function to increment version
increment_version() {
    local version=$1
    local IFS=.
    local -a parts=($version)
    local major="${parts[0]}"
    local minor="${parts[1]}"
    local patch="${parts[2]}"
    
    # Increment patch version
    patch=$((patch + 1))
    
    echo "$major.$minor.$patch"
}

# Read current version from build.gradle
CURRENT_VERSION=$(grep "version = '" build.gradle | sed "s/version = '//" | sed "s/'//")
NEW_VERSION=$(increment_version $CURRENT_VERSION)

echo "Build successful! Bumping version from $CURRENT_VERSION to $NEW_VERSION"

# Create a temporary branch for version bump
TEMP_BRANCH="version-bump-$NEW_VERSION"
git checkout -b $TEMP_BRANCH

# Update version in build.gradle
sed -i '' "s/version = '$CURRENT_VERSION'/version = '$NEW_VERSION'/" build.gradle

# Build and tag Docker image
docker build -t pzajko/cicd-application:$NEW_VERSION .
docker push pzajko/cicd-application:$NEW_VERSION

# Update version in kustomization.yaml
sed -i '' "s/newTag: .*/newTag: $NEW_VERSION/" kubernetes/kustomization.yaml

# Create version bump commit
git add build.gradle kubernetes/kustomization.yaml
git commit -m "chore: bump version to $NEW_VERSION"

# Get back to the original branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git checkout -
git merge $TEMP_BRANCH --no-ff -m "merge: version bump $NEW_VERSION"
git branch -d $TEMP_BRANCH

echo "✅ Build verified"
echo "✅ Version bumped to $NEW_VERSION"
echo "✅ Docker image built and pushed"
echo "✅ Kustomization updated"
echo "✅ Version bump committed"
echo ""
echo "You can now push your changes" 