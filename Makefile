# add s3.conf to environment
env_path=./env/s3.conf
include $(env_path)
export $(shell sed 's/=.*//' $(env_path))

AWS_REGION =$(region)
AWS_PROFILE=$(profile)
TF_STATE_S3_BUCKET =$(bucket)
TF_STATE_DYNAMODB_TABLE=$(dynamodb_table)

.PHONY: plan
plan:
	terraform plan
.PHONY: apply
apply:
	terraform apply \
	--auto-approve

.PHONY: destroy
destroy:
	terraform destroy \
	--auto-approve

.PHONY: init-backend
init-backend:
	aws s3api create-bucket --bucket $(TF_STATE_S3_BUCKET) --region $(AWS_REGION) --profile $(AWS_PROFILE) \
	--acl private --create-bucket-configuration LocationConstraint=$(AWS_REGION) 2>/dev/null || true
	
	aws dynamodb create-table --table-name $(TF_STATE_DYNAMODB_TABLE) --region $(AWS_REGION) --profile $(AWS_PROFILE) \
	--key-schema AttributeName=LockID,KeyType=HASH --attribute-definitions AttributeName=LockID,AttributeType=S \
	--provisioned-throughput ReadCapacityUnits=20,WriteCapacityUnits=20 2>/dev/null || true

	terraform init -backend-config=$(env_path)