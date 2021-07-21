.PHONY: default
default: start


.PHONY: dynamodb
dynamodb:
	@scripts/docker-up-dynamodb


.PHONY: start
start:
	docker-compose -f docker-compose.localdev.yml pull --include-deps
	foreman start -e /dev/null


.PHONY: test
test:
	@scripts/docker-up-test
	@echo ' ____'
	@echo '|  _ \ __ _ ___ ___ '
	@echo '| |_) / _` / __/ __|'
	@echo '|  __/ (_| \__ \__ \'
	@echo '|_|   \__,_|___/___/'
