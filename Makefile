CLI_DIR:=$(CURDIR)/components/cli
ENGINE_DIR:=$(CURDIR)/components/engine
PACKAGING_DIR:=$(CURDIR)/components/packaging
VERSION=$(shell cat VERSION)
ARCH:=$(shell $(CURDIR)/detect_arch)

.PHONY: help
help: ## show make targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf " \033[36m%-20s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: prepare
prepare: ## prepare the components
	VERSION=$(VERSION) ./scripts/prepare

.PHONY: static
static:  ## build static packages
	$(MAKE) VERSION=$(VERSION) CLI_DIR=$(CLI_DIR) ENGINE_DIR=$(ENGINE_DIR) -C $(PACKAGING_DIR) ros-static-$(ARCH)
	mkdir -p $(CURDIR)/dist/
	cp -r components/packaging/static/build/* $(CURDIR)/dist/

.PHONY: release
release: static ## release
	VERSION=$(VERSION) ./scripts/release

.PHONY: clean
clean: ## clean the build artifacts
	-$(MAKE) -C $(CLI_DIR) clean
	-$(MAKE) -C $(ENGINE_DIR) clean
	-$(MAKE) -C $(PACKAGING_DIR) clean
	rm -rf dist
	rm -rf components
