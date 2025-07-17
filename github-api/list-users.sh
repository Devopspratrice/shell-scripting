#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with specific access levels
function list_users_by_permission {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    local response
    response="$(github_api_get "$endpoint")"

    # Check if API call failed
    if [[ $? -ne 0 || -z "$response" ]]; then
        echo "Failed to connect to GitHub API or empty response."
        exit 1
    fi

    echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
    echo "$response" | jq -r '.[] | select(.permissions.pull == true and .permissions.push != true and .permissions.admin != true) | "- \(.login)"'
    echo ""

    echo "Users with write access to ${REPO_OWNER}/${REPO_NAME}:"
    echo "$response" | jq -r '.[] | select(.permissions.push == true and .permissions.admin != true) | "- \(.login)"'
    echo ""

    echo "Users with admin access to ${REPO_OWNER}/${REPO_NAME}:"
    echo "$response" | jq -r '.[] | select(.permissions.admin == true) | "- \(.login)"'
    echo ""
}

# Main script
if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

echo "Listing users by permission level for ${REPO_OWNER}/${REPO_NAME}..."
list_users_by_permission

