CLI_DIR:=$(CURDIR)/components/cli
ENGINE_DIR:=$(CURDIR)/components/engine
PACKAGING_DIR:=$(CURDIR)/components/packaging
VERSION=$(shell cat VERSION)

.PHONY: help
help: ## show make targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf " \033[36m%-20s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: test-integration-cli
test-integration-cli: $(CLI_DIR)/build/docker ## test integration of cli and engine
	$(MAKE) -C $(ENGINE_DIR) DOCKER_CLI_PATH=$< test-integration-cli

$(CLI_DIR)/build/docker:
	$(MAKE) -C $(CLI_DIR) -f docker.Makefile build

.PHONY: prepare
release: prepare
	VERSION=$(VERSION) ./scripts/prepare

.PHONY: static
static: prepare ## build static packages
	$(MAKE) VERSION=$(VERSION) CLI_DIR=$(CLI_DIR) ENGINE_DIR=$(ENGINE_DIR) -C $(PACKAGING_DIR) static
	cp -r components/packaging/static/build/* ${CURDIR}/dist/


.PHONY: release
release: static
	VERSION=$(VERSION) ./scripts/release

.PHONY: clean
clean: ## clean the build artifacts
	-$(MAKE) -C $(CLI_DIR) clean
	-$(MAKE) -C $(ENGINE_DIR) clean
	-$(MAKE) -C $(PACKAGING_DIR) clean
	rm -rf dist
	rm -rf components
