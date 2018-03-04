import 'dart:io';

import 'package:cs61a_scheme/builder.dart';
import 'package:grinder/grinder.dart';
import 'package:dart_style/dart_style.dart';

main(args) => grind(args);

@DefaultTask('Build the project.')
build() async {
  await buildLibrary("core/standard_library");
  await buildLibrary("extra/extra_library");
  await buildLibrary("web/web_library");
  await buildLibrary("web/turtle_library");
}

buildLibrary(String name) async {
  String source = await new File("lib/src/$name.dart").readAsString();
  String mixin = generateImportMixin(source);
  String dottedName = name.replaceAll("/", ".");
  String code = "part of cs61a_scheme.${dottedName};\n\n$mixin";
  code = new DartFormatter(pageWidth: 100).format(code);
  var output = new File("lib/gen/$name.gen.dart");
  if (!await output.exists()) await output.create(recursive: true);
  await output.writeAsString(code);
}
