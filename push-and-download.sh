#!/bin/bash
# Push, wait for build, download & extract firmware to Desktop

REPO="bakertk/zmk-config"
BRANCH="totem"
DESKTOP="/c/Users/Grace.iPC/OneDrive/Desktop"
DEST="$DESKTOP/Totem"

# Push to remote
echo "Pushing to $BRANCH..."
git push origin "$BRANCH" || { echo "Push failed"; exit 1; }

# Wait a moment for GitHub to register the run
sleep 5

# Get the latest workflow run for this branch
echo "Waiting for build to start..."
RUN_ID=$(gh run list --repo "$REPO" --branch "$BRANCH" --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
    echo "Could not find a workflow run. Check GitHub Actions."
    exit 1
fi

echo "Watching run $RUN_ID..."
gh run watch "$RUN_ID" --repo "$REPO" --exit-status || { echo "Build failed!"; exit 1; }

# Download the artifact
echo "Downloading firmware..."
mkdir -p "$DEST"
gh run download "$RUN_ID" --repo "$REPO" --dir "$DEST" || { echo "Download failed"; exit 1; }

# Open the folder in Explorer
echo "Opening $DEST..."
explorer.exe "$(cygpath -w "$DEST")"

echo "Done!"
