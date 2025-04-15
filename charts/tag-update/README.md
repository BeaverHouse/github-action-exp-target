# Tag update Helm chart

This folder is the sample folder structure for the tag update workflow, from the perspective of the target repository.
I just placed only the `values.yaml` file for now. Imagine that you have a Helm chart with something…

## How the workflow works

[Sample workflow file](.github/workflows/helm-tag-updates.yml)

It's triggered by the `workflow_dispatch` event, or `workflow_call` event from the source repository.

> [!NOTE]
> Auto-merge is only available for public repos if you're using free account or organization.

### Steps

1. Checkout the target repository
2. Install yq
3. Give permission to scripts
4. Update image tags, using `helm-tag-updates.sh`
5. Create the pull request.  
   It uses `GITHUB_TOKEN` to create the pull request, so the bot will be the author of the pull request.
6. Check if the auto-merge is allowed.
   - There may be some cases that `auto_merge` input is `true`, but the change includes the `production` values.yaml file.
   - In that case, the workflow will not allow the auto-merge.
7. If the auto-merge is allowed, approve the pull request.
   - Approver must be different from the author of the pull request.
   - So we need to use PAT, so that the user approves the bot's pull request.
8. Auto-merge will be triggered.
