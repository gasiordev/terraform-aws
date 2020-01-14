DIR_NETWORK=network
DIR_BASE=base
DIR_APPS=apps
CFG_FILE=../../config.tfvars

help:
	@echo "Targets: start_network_all"
	@echo "         start_base_all"
	@echo "         start_apps_all"
	@echo "         destroy_network_all"
	@echo "         destroy_base_all"
	@echo "         destroy_apps_all"
	@echo "         promote_failover"

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

start_network-%:
	@cd $(DIR_NETWORK)/${*} && terraform init && terraform apply -var-file=$(CFG_FILE) -auto-approve

destroy_network-%:
	@cd $(DIR_NETWORK)/${*} && terraform init && terraform destroy -var-file=$(CFG_FILE) -auto-approve || true

start_base-%:
	@cd $(DIR_BASE)/${*} && terraform init && terraform apply -var-file=$(CFG_FILE) -auto-approve

destroy_base-%:
	@cd $(DIR_BASE)/${*} && terraform init && terraform destroy -var-file=$(CFG_FILE) -auto-approve || true

start_apps-%:
	@cd $(DIR_APPS)/${*} && terraform init && terraform apply -var-file=$(CFG_FILE) -auto-approve

destroy_apps-%:
	@cd $(DIR_APPS)/${*} && terraform init && terraform destroy -var-file=$(CFG_FILE) -auto-approve || true

start_network_all: start_network-10_production start_network-20_failover start_network-30_staging start_network-40_dev

destroy_network_all: destroy_network-40_dev destroy_network-30_staging destroy_network-20_failover destroy_network-10_production

start_base_all: start_base-00_global start_base-10_production start_base-20_failover

destroy_base_all: destroy_base-20_failover destroy_base-10_production destroy_base-00_global

start_apps_all: start_apps-15_production_and_failover

destroy_apps_all: destroy_apps-15_production_and_failover

promote_failover:
	@cd $(DIR_APPS)/15_production_and_failover && terraform init && terraform apply -var-file=$(CFG_FILE) -var 'failover_db_replication=false' -var 'failover_s3_bucket_replication=false' -auto-approve && echo "!!! Failover is now promoted. Update configurations"

