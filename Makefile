.PHONY: npmjs tests

SHELL := $(shell command -v bash)
DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
basename := $(shell basename $(DIR))
NODE_NO_WARNINGS := 1
START_SERVER_AND_TEST_INSECURE := 1
export NODE_NO_WARNINGS
export START_SERVER_AND_TEST_INSECURE

npmjs:
	@npm run npmjs

worker-bbin-dev:
	@npm start -w bbin

worker-bbin-publish:
	@npm publish -w bbin

worker-bbin-tests:
	@npm publish -w bbin

tests-npm:
	@npm run test

tests-bats:
	@bats
