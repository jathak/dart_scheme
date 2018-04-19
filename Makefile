.PHONY: deploy checks serve build

serve:
	pub get
	pub run build_runner serve

build:
	pub get
	pub run build_runner build --release --output web:deploy

deploy: build
	# Delete random Dart build artifacts
	-cd deploy && rm -r packages .build.manifest .packages main.dart.js.deps \
		main.dart.js.map main.dart.js.tar.gz main.module main.dart
	# Dokku static buildpack
	touch deploy/.static
	# The static Dokku buildpack weirdly has missing URIs display index.html
	# instead of 404-ing. This custom config should fix that.
	cp tool/app-nginx.conf.sigil deploy/app-nginx.conf.sigil
	echo "404 Not Found" > deploy/404.txt
	# Because application cache is horrible even when you remove it
	printf "CACHE MANIFEST\nNETWORK:\n*" > deploy/app.appcache 
	bash tool/deploy.sh

checks:
	pub run test
	pub run grinder check
	pub run dependency_validator
	pub run dart_style:format -n .
	dartanalyzer --fatal-warnings --strong .

