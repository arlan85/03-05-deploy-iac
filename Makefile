# https://github.com/aws-cloudformation/cfn-lint

STACK_NAME := iac-$(shell git rev-parse --short HEAD)
PARAMS = GitHubRepository=automate6500/lambda-cicd

lint:
	cfn-lint terraform-service-account-cloudformation-template.yml

deploy:
	rain deploy terraform-service-account-cloudformation-template.yml $(STACK_NAME) \
		--yes --params $(PARAMS)

amis:
	aws ec2 describe-images \
	  --owners 099720109477 \
	  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*" \
	  --query 'Images | sort_by(@, &CreationDate) | [-5:].[Name,ImageId,CreationDate]' \
	  --output table

refresh init validate fmt:
	terraform $(@)

plan:
	terraform plan

quiet-init:
	@terraform init > /dev/null
	@if [ $$? -eq 0 ]; then \
		echo "- Initialization successful"; \
	else \
		echo "- Error during initialization"; \
		exit 1; \
	fi

# 0 = Succeeded with empty diff (no changes)
# 1 = Error
# 2 = Succeeded with non-empty diff (changes present)
quiet-plan:
	@terraform plan -detailed-exitcode > /dev/null
	@if [ $$? -eq 0 ]; then \
		echo "- No changes detected"; \
		exit 0; \
	elif [ $$? -eq 2 ]; then \
		echo "- Changes detected"; \
		exit 2; \
	else \
		echo "- Error in plan"; \
		exit 1; \
	fi

upgrade:
	terraform init -upgrade

reconfigure:
	terraform init -reconfigure

apply approve:
	terraform apply -auto-approve

list:
	terraform state list

update:
	terraform get -update

