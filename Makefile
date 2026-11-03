.PHONY: install build dev stop a i

PLATFORM ?= all

install:
	@if [ -n "$(filter a i,$(MAKECMDGOALS))" ]; then \
		python3 tools/dev.py install $(filter a i,$(MAKECMDGOALS)); \
	else \
		python3 tools/install.py $(PLATFORM); \
	fi

build:
	@python3 tools/build.py $(filter a i,$(MAKECMDGOALS))

dev:
	@python3 tools/dev.py start $(filter a i,$(MAKECMDGOALS))

a i:
	@:

stop:
	@python3 tools/dev.py stop
