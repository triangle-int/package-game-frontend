.PHONY: install dev stop

PLATFORM ?= all

install:
	@python3 tools/install.py $(PLATFORM)

dev:
	@python3 tools/dev.py start

stop:
	@python3 tools/dev.py stop
