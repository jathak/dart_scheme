.PHONY: deploy checks

deploy:
	pub get
	pub build
	touch build/web/.static
	-rm -r build/web/packages
	bash tool/deploy.sh

checks:
	pub run test
	pub run grinder check
	pub run dependency_validator
	pub run dart_style:format -n .
	dartanalyzer --fatal-warnings --strong .