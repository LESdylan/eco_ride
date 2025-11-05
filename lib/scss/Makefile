# Color codes
GREEN  = \033[0;32m
YELLOW = \033[1;33m
BLUE   = \033[0;34m
NC     = \033[0m

# Paths
SCSS_DIR = .
CSS_DIR = ./css
MAIN_SCSS = $(SCSS_DIR)/main.scss
OUTPUT_CSS = $(CSS_DIR)/style.css
OUTPUT_MIN = $(CSS_DIR)/style.min.css

# Allow overriding the Sass binary (e.g., make SASS="npx sass")
SASS ?= npx sass

# Logging
define info
	@echo "$(BLUE)[INFO]$(NC) $(1)"
endef

define success
	@echo "$(GREEN)[SUCCESS]$(NC) $(1)"
endef

# Detect Sass flavor and set flags
SASS_VERSION := $(shell $(SASS) --version 2>/dev/null || echo "unknown")
# Ruby Sass expects --sourcemap=none, Dart Sass uses --no-source-map
ifneq (,$(findstring Ruby,$(SASS_VERSION)))
	NO_MAP_FLAG := --sourcemap=none
else
	NO_MAP_FLAG := --no-source-map
endif
STYLE_FLAG := --style=compressed
WATCH_FLAG := --watch
LOAD_PATH_FLAG := --load-path=$(SCSS_DIR)

# Targets
all: build

re: clean build

# Ensure we are using Dart Sass (module system @use support)
require-dart:
	@if ! $(SASS) --version 2>/dev/null | grep -qiE "(dart|1\.)"; then \
		echo "[ERROR] Dart Sass is required (supports @use). Current: $$($(SASS) --version 2>/dev/null || echo 'not found')"; \
		echo "Tip: install with 'npm install -g sass' or use 'make SASS=\"npx sass\"'"; \
		exit 2; \
	fi

build: require-dart
	$(call info,Compiling SCSS to CSS...)
	@mkdir -p $(CSS_DIR)
	$(SASS) $(MAIN_SCSS) $(OUTPUT_CSS) $(NO_MAP_FLAG) $(LOAD_PATH_FLAG)
	@test -s $(OUTPUT_CSS) || (echo "[ERROR] CSS not generated at $(OUTPUT_CSS)"; exit 1)
	@! grep -qE '@use|@mixin|@function|@include' $(OUTPUT_CSS) || (echo "[ERROR] Output contains Sass directives (compilation failed)"; exit 1)
	$(call success,CSS compiled to $(OUTPUT_CSS))

minify: build
	$(call info,Minifying CSS...)
	$(SASS) $(MAIN_SCSS) $(OUTPUT_MIN) $(STYLE_FLAG) $(NO_MAP_FLAG) $(LOAD_PATH_FLAG)
	@test -s $(OUTPUT_MIN) || (echo "[ERROR] Minified CSS not generated at $(OUTPUT_MIN)"; exit 1)
	@! grep -qE '@use|@mixin|@function|@include' $(OUTPUT_MIN) || (echo "[ERROR] Minified output contains Sass directives (compilation failed)"; exit 1)
	$(call success,Minified CSS created at $(OUTPUT_MIN))

watch: require-dart
	$(call info,Watching SCSS files for changes...)
	$(SASS) $(WATCH_FLAG) $(MAIN_SCSS):$(OUTPUT_CSS) $(NO_MAP_FLAG) $(LOAD_PATH_FLAG)

check:
	$(call info,Verifying generated CSS files...)
	@ls -lah $(OUTPUT_CSS) 2>/dev/null || echo "[WARN] $(OUTPUT_CSS) missing"
	@ls -lah $(OUTPUT_MIN) 2>/dev/null || echo "[WARN] $(OUTPUT_MIN) missing"

print-paths:
	@echo "SASS=$(SASS)"
	@echo "SASS_VERSION=$(SASS_VERSION)"
	@echo "MAIN_SCSS=$(MAIN_SCSS)"
	@echo "OUTPUT_CSS=$(OUTPUT_CSS)"
	@echo "OUTPUT_MIN=$(OUTPUT_MIN)"

clean:
	$(call info,Cleaning generated CSS files...)
	rm -rf $(CSS_DIR)
	$(call success,CSS directory cleaned)

help:
	@echo "$(BLUE)Available targets:$(NC)"
	@echo "  make build    - Compile SCSS to CSS"
	@echo "  make minify   - Compile and minify CSS"
	@echo "  make watch    - Watch for SCSS changes and auto-compile"
	@echo "  make clean    - Remove generated CSS files"
	@echo "  make re       - Clean then build"
	@echo "  make check    - Verify outputs exist"
	@echo "  make print-paths - Print paths and Sass info"
	@echo ""
	@echo "Variables:"
	@echo "  SASS          - Sass command to use (e.g., 'sass' or 'npx sass')"

.PHONY: all build minify watch clean re help check print-paths require-dart
