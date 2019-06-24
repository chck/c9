GCP_PROJECT:=YOUR_GCP_PROJECT_ID
PRODUCT:=cloud9
REGION:=us-west1
ZONE:=$(REGION)-c
IMAGE_FAMILY:=ubuntu-1804-lts
IMAGE_PROJECT:=ubuntu-os-cloud

.PHONY: all
all: help

.PHONY: set ## Set a GCP project
set:
	gcloud config set project $(GCP_PROJECT)

.PHONY: create ## Create a GCE instance
create:
	@make set
	@make book-ip
	gcloud compute instances create $(PRODUCT)-instance \
		--zone $(ZONE) --machine-type f1-micro --network default \
		--address $(PRODUCT)-ip --image-family $(IMAGE_FAMILY) \
		--image-project $(IMAGE_PROJECT) --boot-disk-size 30 \
		--boot-disk-type pd-standard --boot-disk-device-name $(PRODUCT)-instance

.PHONY: book-ip ## Reserve static ip on GCP
book-ip:
	gcloud compute addresses create $(PRODUCT)-ip --region $(REGION)
	gcloud compute addresses list --filter="region:( $(REGION) )"

.PHONY: delete ## Delete the GCE instance and the reserved ip
delete:
	gcloud compute addresses delete $(PRODUCT)-ip --region $(REGION) --quiet
	gcloud compute instances delete $(PRODUCT)-instance --zone $(ZONE)  --quiet

.PHONY: help ## View help
help:
	@grep -E '^.PHONY: [a-zA-Z_-]+.*?## .*$$' $(MAKEFILE_LIST) | sed 's/^.PHONY: //g' | awk 'BEGIN {FS = "## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
