ADDON  := HoarderMate

# Override with: make install WOW_ADDONS=/path/to/AddOns
# C:\Program Files (x86)\Blizzard\World of Warcraft\_classic_era_\Interface\AddOns
ifeq ($(OS),Windows_NT)
    WOW_ADDONS ?= C:\Program Files (x86)\Blizzard\World of Warcraft\_classic_era_\Interface\AddOns
else
    UNAME := $(shell uname -s)
    ifeq ($(UNAME),Darwin)
        WOW_ADDONS ?= /Applications/World of Warcraft/_classic_era_/Interface/AddOns
    else
        WOW_ADDONS ?= $(HOME)/games/wow/_classic_era_/Interface/AddOns
    endif
endif

DEST := $(WOW_ADDONS)/$(ADDON)

.PHONY: install clean version

install:
	rm -rf "$(DEST)"
	cp -r "$(ADDON)" "$(DEST)"
	@echo "Installed $(ADDON) to $(DEST)"

clean:
	rm -rf "$(DEST)"
	@echo "Removed $(ADDON) from $(DEST)"

# Bump version locally: make version v=1.2.3
version:
	@if [ -z "$(v)" ]; then echo "Usage: make version v=1.2.3"; exit 1; fi
	@echo "$(v)" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$$' || (echo "Invalid semver: $(v)"; exit 1)
	perl -pi -e 's/^## Version:.*$$/## Version: $(v)/' $(ADDON)/$(ADDON).toc
	@echo "Version bumped to $(v) in $(ADDON)/$(ADDON).toc"
