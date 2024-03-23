.SHELLFLAGS = -ec
.ONESHELL:

# Bump version variables
BASE_BRANCH ?= "main"
DRY_RUN ?= "false"

# Devcontainer variables
FEATURES ?= common-utils ## Feature to test. Default: 'common-utils'. Options: 'aws-cli', 'common-utils', 'docker-in-docker', 'docker-outside-of-docker'
BASE_IMAGE ?= archlinux:base ## Base image for testing. Must be Arch Linux with 'pacman'. Default: 'archlinux:base'.
PATH_TO_RUN ?= . ## Path to run the tests. Default: . (current directory). Change this in the Makefile or in the environment.

# Devcontainer command
DEVCONTAINER=devcontainer
DEVCONTAINER_TEST=$(DEVCONTAINER) features test

# Devcontainer flags
DEVCONTAINER_TEST_GLOBAL_FLAGS=--global-scenarios-only
DEVCONTAINER_TEST_AUTOGENERATED_FLAGS=--skip-scenarios -f $(FEATURES) -i $(BASE_IMAGE)
DEVCONTAINER_TEST_SCENARIOS_FLAGS=-f $(FEATURES) --skip-autogenerated --skip-duplicated

.PHONY: help
help: ## Display this help message.
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m    %-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variables:"
	@awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+\s*\?=\s*.*?## / {split($$1, a, "\\s*\\?=\\s*"); printf "\033[33m    %-30s\033[0m %s\n", a[1], $$2}' $(MAKEFILE_LIST)

.PHONY: test-global
test-global: ## Run global scenario tests.
	$(DEVCONTAINER_TEST) $(DEVCONTAINER_TEST_GLOBAL_FLAGS) $(PATH_TO_RUN)

.PHONY: test-autogenerated
test-autogenerated: ## Run autogenerated tests for a specific feature against a base image. Arguments: FEATURES, BASE_IMAGE.
	$(DEVCONTAINER_TEST) $(DEVCONTAINER_TEST_AUTOGENERATED_FLAGS) $(PATH_TO_RUN)

.PHONY: test-scenarios
test-scenarios: ## Run scenario tests for a specific feature. Argument: FEATURES.
	$(DEVCONTAINER_TEST) $(DEVCONTAINER_TEST_SCENARIOS_FLAGS) $(PATH_TO_RUN)

.PHONY: bump-version
bump-version: ## Run bump_version.sh script. Arguments: BASE_BRANCH, DRY_RUN.
	./scripts/bump_version.sh $(BASE_BRANCH) $(DRY_RUN)