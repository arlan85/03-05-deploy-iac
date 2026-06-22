# 03_05 Continuous Deployment for Infrastructure as Code

GitHub Actions provides **Step summaries** to surface meaningful workflow output directly in the GitHub interface. Instead of digging through raw logs, step summaries provide easy-to-access, Markdown-formatted summaries for workflow runs.

## Common Uses for Step Summaries

- Report test results
- Summarize build or deployment output
- Highlight key changes or metrics
- Provide reviewer-friendly context in pull requests

## What is `GITHUB_STEP_SUMMARY`?

- A built-in GitHub Actions variable
- Contains a **file path** where a workflow step can write text
- Any content written to this file appears in the **workflow summary**
- Content is rendered as **GitHub Flavored Markdown**, including emojis

## Writing to the Step Summary

### Bash / Linux runners

```bash
echo "### Summary Title" >> $GITHUB_STEP_SUMMARY
```

### PowerShell runners

```powershell
"### Summary Title" >> $env:GITHUB_STEP_SUMMARY
```

- Use `>>` to **append** content
- Each step can add to the same summary file

## Terraform + Step Summaries

- `terraform plan` generates a report describing proposed infrastructure changes
- Raw plan output can be difficult to scan in logs
- CLI tools like `awk` and `sed` can:

  - Extract relevant sections
  - Reformat output as Markdown

- The formatted plan can be written to `GITHUB_STEP_SUMMARY`
- This allows teams to **review infrastructure changes before apply**

## Why This Matters

- Improves visibility for workflow runs
- Makes pull requests more informative
- Reduces reliance on raw logs
- Adds a review checkpoint for infrastructure changes

## References

| Reference | Description |
|----------|-------------|
| [LinkedIn Learning Course: Learning Terraform](https://www.linkedin.com/learning/learning-terraform-15575129/learn-terraform-for-your-cloud-infrastructure) | Comprehensive LinkedIn Learning course covering Terraform fundamentals |
| [About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches) | Official GitHub documentation explaining branch protection rules and availability |
| [Adding a job summary](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands#adding-a-job-summary) | GitHub Actions documentation for creating job summaries |
| [Supercharging GitHub Actions with Job Summaries](https://github.blog/news-insights/product-news/supercharging-github-actions-with-job-summaries/) | GitHub blog post introducing job summaries feature |
| [GitHub Flavored Markdown Spec](https://github.github.com/gfm/) | Official specification for GitHub Flavored Markdown |

> [!IMPORTANT]
> Protected branches are available in **public repositories** with **GitHub Free** and GitHub Free for organizations. Protected branches are also available in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see GitHub's plans.

## Lab: Using Terraform Plans and Step Summaries in GitHub Actions

In this lab, you’ll configure a GitHub repository to run a Terraform-based workflow that uses **step summaries** to present infrastructure changes clearly—both in workflow runs and pull requests. You’ll also apply repository protections to reinforce best practices around review and deployment approvals.

> [!TIP]
> If you run into issues with the lab, please refer to the [lab troubleshooting document](./LAB_TROUBLESHOOTING.md)

### Prerequisites

Before you begin, make sure you have:

- A **GitHub account**
- An **AWS account** with permission to deploy CloudFormation stacks
- The exercise files downloaded locally

> [!IMPORTANT]
> If your GitHub account is on the free plan, the repository you create for this lab **must be public** to use branch protection rules as needed in the lab.

### Step 0: Deploy the CloudFormation Stack to Create a Service Account

Use the provided CloudFormation template to create the AWS resources needed to bootstrap this lab.

- [Terraform service account CloudFormation template](./terraform-service-account-cloudformation-template.yml)

Refer to the lab in [03_03 Create a Service account for Deployments](../03_03_create_a_service_account_for_deployments/README.md#lab-provision-a-service-account-and-deployment-targets-configure-github-actions-for-aws-deployments) for the steps to deploy the template.

### Step 1: Create and Populate the Repository

1. Create a new GitHub repository.
2. When creating the repository:

   - Add a **README.md**
   - Add a **.gitignore** file for **Terraform**

3. Upload all exercise files into the repository.

   - Do **not** move any workflow files yet.
   - The workflow files will be relocated later on in the lab.

Once the files are uploaded, you’re ready to configure repository settings.

### Step 2: Protect the `main` Branch

To ensure all infrastructure changes go through review, you’ll add a branch protection rule.

1. Open the repository **Settings**
2. Under **Code and automation**, select **Branches**.
3. Choose **Add classic branch protection rule**
4. Configure the rule:

   - **Branch name pattern:** `main`
   - Enable **Require a pull request before merging**

5. Scroll to the bottom and select **Create**
6. If prompted, confirm the change using your **two-factor authentication code**

At this point, the `main` branch is protected and cannot be modified directly.

### Step 3: Create a Protected Deployment Environment

Next, you’ll create an environment that requires approval before deployments run.

1. In repository **Settings**, select **Environments**
2. Select **New environment**
3. Name the environment **Production** with a capital "P".
4. Select **Configure environment**
5. Enable **Required reviewers**
6. Add yourself as an approver
7. Save the protection rules

Any workflow targeting the **Production** environment will now pause and wait for approval.

### Step 4: Add Repository Variables for AWS Authentication

The workflows in this lab [authenticate to AWS using OpenID Connect](https://docs.github.com/en/actions/concepts/security/openid-connect) and repository variables.

1. In repository **Settings**, select **Secrets and variables**
2. Select **Actions**
3. Open the **Variables** tab
4. Create the following repository variables using values from your CloudFormation stack outputs:

| Variable Name            | Description                        |
| ------------------------ | ---------------------------------- |
| `AWS_REGION`             | AWS region from the stack outputs  |
| `AWS_ROLE_ARN`           | IAM role ARN for GitHub Actions    |
| `TERRAFORM_STATE_BUCKET` | S3 bucket name for Terraform state |

Once these variables are set, the workflows are ready to authenticate with AWS.

### Step 5: Enable the Terraform Pipeline Workflow

Now you’ll activate the main Terraform workflow.

1. Open the **Code** tab
2. Open the file `00-terraform-pipeline.yml`
3. Select the **Edit** (pencil) icon
4. Rename the file to:

    ```bash
    .github/workflows/00-terraform-pipeline.yml
    ```

#### Review the Workflow Configuration for Step Summaries

Before committing, take a moment to review where step summaries are written in the workflow:

- Validation results written to `GITHUB_STEP_SUMMARY`
- Terraform plan summary appended from `plan.md`
- Terraform apply summary appended from `apply.md`

This is how the workflow surfaces meaningful results without relying on raw logs.

### Step 6: Commit the Workflow Using a Pull Request

Because the `main` branch is protected, you’ll commit this change using a pull request.

1. Commit the change
2. Confirm **Create a new branch for this commit and start a pull request** is selected
3. Select **Propose changes**
4. Create the pull request using the default title

Once the pull request is created, the workflow runs automatically.

### Step 7: Review Step Summaries in the Pull Request

As the workflow runs, the pull request updates with a summary of the Terraform plan.

- Review the proposed infrastructure changes
- Confirm the changes match your expectations

If everything looks good, proceed to merge the pull request.

Since this is a single-user lab, you may bypass the branch protection rule and merge.

### Step 8: Approve the Production Deployment

After the pull request is merged:

1. Open the **Actions** tab
2. Select the **00-Terraform Pipeline** workflow
3. When prompted, select **Review deployments**
4. Choose **Production**
5. Select **Approve and deploy**

The workflow resumes and applies the Terraform changes.

Once complete, review the final step summary showing the applied changes and output links.

### Step 9: Verify the Deployed Application

The apply summary includes links to the EC2 instances Terraform deployed.

- Select one of the links
- Confirm the application is running

Using step summaries, you were able to follow the entire pipeline without opening individual logs.

### Cleanup: Removing the Lab Environment

When you’re ready to clean up the resources created in this lab, follow these high-level steps:

1. Disable the **00-Terraform Pipeline** workflow
2. Remove the branch protection rule on `main`
3. Delete the **Production** environment
4. Rename `99-destroy-resources.yml` to:

    ```bash
    .github/workflows/99-destroy-resources.yml
    ```

5. Go to the **Actions** tab
6. Run the **99-Destroy Resources** workflow using the workflow dispatch trigger
7. After resources are destroyed, open the **AWS Console**
8. Delete the CloudFormation stack used for this lab

> [!IMPORTANT]
> Deleting the CloudFormation stack will **not** delete the S3 bucket or its contents. This is intentional. The bucket is retained to prevent accidental loss of Terraform state and must be removed manually later if desired.

### Lab Complete

After completing this lab, you will have used step summaries to make Terraform workflows easier to understand, safer to review, and more effective for collaboration—without relying on raw logs.

<!-- FooterStart -->
---
[← 03_04 Continuous Deployment for Lambda Functions](../03_04_cd_for_lambda/README.md) | [03_06 Challenge: Build a Full CI/CD Pipeline →](../03_06_challenge_cicd_pipeline/README.md)
<!-- FooterEnd -->
