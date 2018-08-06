.PHONY: deploy checks build

build:
	pub get
	pub global activate webdev
	pub global run webdev build --release

deploy: build
	# Delete random Dart build artifacts
	-cd build && rm -r packages .build.manifest .packages main.dart.js.deps \
		main.dart.js.map main.dart.js.tar.gz main.module main.dart
	# Dokku static buildpack
	touch build/.static
	# The static Dokku buildpack weirdly has missing URIs display index.html
	# instead of 404-ing. This custom config should fix that.
	cp tool/app-nginx.conf.sigil build/app-nginx.conf.sigil
	echo "404 Not Found" > build/404.txt
	# Because application cache is horrible even when you remove it
	printf "CACHE MANIFEST\nNETWORK:\n*" > build/app.appcache 
	bash tool/deploy.sh

checks:
	pub run test
	pub run grinder check
	pub run dependency_validator --ignore build_runner,build_web_compilers,sass_builder
	dartfmt -n .
	dartanalyzer --fatal-warnings .

