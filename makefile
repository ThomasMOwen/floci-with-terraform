WORKDIR = $(PWD)
TF = docker run --rm -it --network=floci-env -v $(WORKDIR):/workspace -w /workspace hashicorp/terraform:latest

version:
	$(TF) version

init: 
	$(TF) init -reconfigure

plan:
	$(TF) plan

validate:
	$(TF) validate

fmt:
	$(TF) fmt -diff -recursive

apply:
	$(TF) apply	

lint:
	docker run --rm -v $(WORKDIR):/data ghcr.io/terraform-linters/tflint

scan:
	docker run --rm -v $(WORKDIR):/workspace aquasec/trivy:latest config /workspace