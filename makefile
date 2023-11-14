.DEFAULT_GOAL := run_all

USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)
DOCKER_USER := ${USER_ID}:${GROUP_ID}

CURRENT_DIR := $(shell pwd)
STYLE_CHECK_IGNORE := $(shell paste -sd, .phpcsignore)

run_all: run_phpunit_tests run_stylecheck

run_phpunit_tests: run_phpunit_test_php55 run_phpunit_test_php56 run_phpunit_test_php70

run_phpunit_test_php55:
	rm -rf reports/php55
	mkdir -p reports/php55
	docker-compose run --rm phpunit-php55 \
		--coverage-clover=/app/reports/php55/coverage/coverage.xml \
		--coverage-html=/app/reports/php55/coverage/html \
		--log-junit=/app/reports/php55/junit.xml

run_phpunit_test_php56:
	rm -rf reports/php56
	mkdir -p reports/php56
	docker-compose run --rm phpunit-php56 \
		--coverage-clover=/app/reports/php56/coverage/coverage.xml \
		--coverage-html=/app/reports/php56/coverage/html \
		--log-junit=/app/reports/php56/junit.xml

run_phpunit_test_php70:
	rm -rf reports/php70
	mkdir -p reports/php70
	docker-compose run --rm phpunit-php70 \
		--coverage-clover=/app/reports/php70/coverage/coverage.xml \
		--coverage-html=/app/reports/php70/coverage/html \
		--log-junit=/app/reports/php70/junit.xml

run_stylecheck:
	rm -rf reports/style
	mkdir -p reports/style
	docker-compose run --rm phpcs \
			 -p \
			--standard=PSR12 \
			--ignore="${STYLE_CHECK_IGNORE}" \
			--basepath=/app \
			--report-file=/app/reports/style/checkstyle.xml \
			--runtime-set ignore_errors_on_exit 1 \
			--runtime-set ignore_warnings_on_exit 1 \
			--report=checkstyle /app

build: build_php55 build_php56 build_php70 build_phpcs

build_php55:
	docker-compose build phpunit-php55

build_php56:
	docker-compose build phpunit-php56

build_php70:
	docker-compose build phpunit-php70

build_phpcs:
	docker-compose build phpcs
