RUN = pipenv run

setup: ## Prepare your local workspace
	pipenv install

validate: ## Validate your configuration files
	$(RUN) octodns-validate --config-file config.yaml
	@echo Config files successfully validated!

dry-run: ## Dry-run DNS record update (SAFE)
	@$(RUN) octodns-sync --config-file config.yaml

run: check ## Run DNS record update (!!!)
	$(RUN) octodns-sync --config-file config.yaml --doit


%:
	@true

.PHONY: help

check: # A sanity check
	@echo Warning: "Warning: This is a destructive action! Continue? [Y/n]"
	@read line; if [ $$line = "n" ]; then echo aborting; exit 1 ; fi

help:
	@echo 'Usage: make <command>'
	@echo
	@echo 'where <command> is one of the following:'
	@echo
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
