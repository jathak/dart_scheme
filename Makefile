.PHONY: deploy checks

deploy:
	pub get
	pub build
	touch build/web/.static
	-rm -r build/web/packages
	# The static Dokku buildpack weirdly has missing URIs display index.html
	# instead of 404-ing. This custom config should fix that.
	cp tool/app-nginx.conf.sigil build/web/app-nginx.conf.sigil
	echo "404 Not Found" > build/web/404.txt
	bash tool/deploy.sh

checks:
	pub run test
	pub run grinder check
	pub run dependency_validator
	pub run dart_style:format -n .
	dartanalyzer --fatal-warnings --strong .
