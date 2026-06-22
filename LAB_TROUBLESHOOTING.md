# Checklist and Troubleshooting for Terraform + Step Summaries Lab

## Checklist

Use this checklist to confirm you’ve completed each part of the lab successfully.

### Repository Setup

- ⬜ Created a **public** GitHub repository
- ⬜ Added a `README.md`
- ⬜ Added a Terraform `.gitignore`
- ⬜ Uploaded all exercise files without moving workflow files

### Repository Protections

- ⬜ Added a branch protection rule for `main`

  - ⬜ Requires pull requests before merging
- ⬜ Created a **Production** environment

  - ⬜ Required reviewer configured
  - ⬜ Environment approval pauses deployments

### AWS & GitHub Configuration

- ⬜ Deployed the CloudFormation stack for the service account
- ⬜ Added repository variables:

  - ⬜ `AWS_REGION`
  - ⬜ `AWS_ROLE_ARN`
  - ⬜ `TERRAFORM_STATE_BUCKET`

### Workflow Execution

- ⬜ Moved `00-terraform-pipeline.yml` into `.github/workflows/`
- ⬜ Verified step summaries exist in:

  - ⬜ Validation step
  - ⬜ Terraform plan step
  - ⬜ Terraform apply step
- ⬜ Created a pull request to trigger the workflow
- ⬜ Reviewed Terraform plan in the pull request summary
- ⬜ Merged the pull request

### Deployment & Verification

- ⬜ Approved the **Production** deployment
- ⬜ Verified the Terraform apply summary
- ⬜ Opened at least one deployed web server link

### Cleanup (Optional)

- ⬜ Disabled the Terraform pipeline workflow
- ⬜ Removed branch protection
- ⬜ Deleted the Production environment
- ⬜ Ran the **99-Destroy Resources** workflow
- ⬜ Deleted the CloudFormation stack

## Troubleshooting Guide

| Issue                                                    | Symptoms / Possible Causes                                                                              | Fix / Next Steps                                                                                                                                             |
|----------------------------------------------------------|---------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Workflow Does Not Run**                                | - Repository is private<br>- Workflow file is not in `.github/workflows/`                               | - Confirm the repository is public<br>- Verify workflow file path and commit the change                                                                      |
| **AWS Authentication Fails**                             | - Errors during `Configure AWS Credentials`<br>- Access denied or role assumption failures              | - Verify repository variables:<br>&nbsp;&nbsp;&nbsp;&bull; `AWS_REGION`<br>&nbsp;&nbsp;&nbsp;&bull; `AWS_ROLE_ARN`<br>&nbsp;&nbsp;&nbsp;&bull; `TERRAFORM_STATE_BUCKET`<br>- Confirm the CloudFormation stack deployed successfully<br>- Ensure the GitHub repository name matches the OIDC trust policy |
| **Terraform Init Fails**                                 | - Errors initializing the backend<br>- Cannot access the state bucket                                   | - Confirm the S3 bucket name matches `TERRAFORM_STATE_BUCKET`<br>- Ensure the bucket still exists<br>- Check that the IAM role has S3 permissions            |
| **Step Summaries Do Not Appear**                         | - Workflow completes but summary is empty                                                               | - Confirm steps write to `GITHUB_STEP_SUMMARY`<br>- Ensure content is appended using `>>`<br>- Check for syntax errors in shell scripts                      |
| **Pull Request Does Not Show Plan Summary**              | - Workflow runs, but PR has no Terraform plan details                                                   | - Confirm the workflow ran on a `pull_request` event<br>- Verify the PR comment step is configured correctly<br>- Ensure the `GITHUB_TOKEN` has permission to write PR comments      |
| **Deployment Is Stuck Waiting**                          | - Workflow pauses after merge                                                                           | - Open the **Actions** tab<br>- Select **Review deployments**<br>- Approve the **Production** environment                                                   |
| **Destroy Workflow Does Not Remove Resources**           | - Resources remain after running destroy workflow                                                       | - Confirm `99-destroy-resources.yml` is in `.github/workflows/`<br>- Run the workflow using **workflow_dispatch**<br>- Verify Terraform state is intact and accessible       |
| **CloudFormation Stack Deletion Leaves S3 Bucket**       | - The S3 bucket is retained after stack deletion                                                        | - CloudFormation cannot delete buckets with contents<br>- Retaining the bucket prevents Terraform state loss<br>- Manually delete the bucket and its contents when ready     |
