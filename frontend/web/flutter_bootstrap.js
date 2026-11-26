{{flutter_js}}
{{flutter_build_config}}

const releaseTag = Date.now().toString();
for (const build of _flutter.buildConfig.builds) {
  if (build.mainJsPath) {
    const separator = build.mainJsPath.includes('?') ? '&' : '?';
    build.mainJsPath = `${build.mainJsPath}${separator}release=${releaseTag}`;
  }
}

_flutter.loader.load();
