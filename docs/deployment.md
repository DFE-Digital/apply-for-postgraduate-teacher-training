# Deploying Apply - Step by step

The apply build and release process is split into two separate Azure DevOps pipelines.

- [apply-for-teacher-training](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=49&_a=summary): This is the main development CI pipeline which will automatically trigger a build from a commit to any branch within the Apply GitHub code repository. When commits are made to the master branch, this pipeline will also deploy the application to the QA infrastructure environment in Azure automatically.

- [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary): This is the main release pipeline that is used to deploy to all other Azure environments except QA. Releases are triggered manually and the target environments can be chosen prior to deployment.

All members of the Apply development team are able to deploy into any of the environments.

To speed up the release pipeline, logic has been introduced into the pipeline code to only run the full ARM template deployment only if the following conditions are met.
- Any of the pipeline variable groups associated with the deployment have changed since the last successful deployment
- Any of the following files have changed in the commit associated with the build:
  - azure-pipelines.yml
  - azure-pipelines-deploy-template.yml
  - azure-pipelines-release.yml
  - azure/template.json
  - azure/containers.json
If none of the above conditions are met the pipeline will simply load the new image into the container staging slot ready for swapping.

## 1. Check what you're deploying

Go to [the Apply Ops Dashboard](https://apply-ops-dashboard.herokuapp.com/) and find the commit you want to deploy.

Make sure to check the diff on GitHub to see if there's anything risky.

You also have to make sure that you're deploying only work that is safe to deploy. It should be either behind a feature flag or product reviewed.

[Check the QA monitoring dashboard in Azure](https://portal.azure.com/#@platform.education.gov.uk/dashboard/arm/subscriptions/289869cc-7183-46bd-8131-f673c5eb94ba/resourcegroups/s106d01-apply/providers/microsoft.portal/dashboards/s106d01-apply-dashboard) for anomalies before you proceed.

## 2. Tell the team ![](https://cultofthepartyparrot.com/parrots/shipitparrot.gif)

Summarise what you're deploying and tell the team in Slack on the `#twd_apply` channel. Use `:ship_it_parrot:` as required.

## 3. Deploy to staging

1. Load the [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary) page in Azure DevOps.
1. Click the blue "Run pipeline" button (sometimes it says "Queue") at the top right of the page which will open the run pipeline menu.
1. Ensure the branch is set to "master".
1. Specify the commit
1. Under the Variables section, make sure only `deploy_staging` is set to true (this should be the default)
1. Click the Run button to start the deployment.

## 4. Check if staging is deployed successfully

Check the `#twd_apply_tech` channel in Slack for runtime errors from
Sentry or the smoke tests.

## 5. Deploy to production and sandbox

1. Load the [apply-for-teacher-training-releases](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary) page in Azure DevOps.
1. Click the blue "Run pipeline" button (sometimes it says "Queue") at the top right of the page which will open the run pipeline menu.
1. Ensure the branch is set to "master".
1. Specify the commit again - **don't forget this**
1. Under the Variables section set `deploy_staging` to `false` and `deploy_production` and `deploy_sandbox` to `true`.
1. Click the Run button to start the deployment

## 6. Check if production and sandbox are deployed successfully

Check the `#twd_apply_tech` channel in Slack for runtime errors from
Sentry or the smoke tests.

## 7. Move deploy cards to done

Tell your team mates that their work has gone out. They should now move over their deployed cards in "Ready to deploy" to "Product review & launch 🚀" on the [Candidate board](https://trello.com/b/aRIgjf0y/candidate-team-board) and/or [ProVendor board](https://trello.com/b/5IiPW0Ok/team-board-apply).

## Rolling back

_Note that this advice does not apply if you are deploying changes to the Azure
templates. If you deploy breaking Azure template changes, the only way to roll
back is to run a full redeploy._

Because we operate blue/green deployments, the previous version of the app is
always available in the staging slot. To roll back to it, follow these
instructions.

To roll back to an earlier version, see the [Manual Deployment guide](manual-deployment.md).

1. [Obtain elevated permissions using Azure PIM](pim-guide.md)
1. Visit the "staging" slot of the application service by searching
   for it in the Azure portal. e.g. for production, type s106p01-apply-as/staging into the search bar at the top of the screen.
1. Start the staging container by clicking "start", identified by a triangular "play" icon at the top of the main pane
1. Wait for the service to start, checking it by visiting the slot URL, which is displayed at the top right of the main pane
1. Once the staging app is running, you can swap the slots so that the old (staging) version becomes the live version. To do this, click "swap" at the top of the main pane, identified by a pair of arrows pointing in opposite directions
1. Confirm using the dialog that appears that you would like to swap the slots

Once the swap is complete, the old version of the app will be running at the live URL.

You should then shut down the staging slot, which now contains the faulty
version of the code. Do this by repeating the above process to find the staging
slot resource, and — after double checking that it is the _staging_ slot
— clicking "stop".
