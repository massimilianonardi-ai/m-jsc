# jsc

Independent `jsc` JavaScript/CSS source compiler for the technical `m`
ecosystem.

`jsc` owns deterministic source assembly from explicitly authored JSON
descriptors. It does not discover source dependencies, decide project
build goals, download input sources or deploy the resulting output.

## Source and release

```text
bin/jsc               POSIX shell compiler command (package-local)
lib/jsc.lib.js        existing CommonJS compiler engine
res/manual/           package-owned operational references
build.sh              standalone POSIX source-archive packager
tests/                isolated real-runtime integration scenario
```

The compiler's runtime files and manuals stay inside the package's own
materialized `root/`. To build a source-only release payload without
Node.js or `mk`:

```sh
sh build.sh /path/to/new-output-directory
```

The resulting `jsc-v0.1.0-all.tar.gz` contains `bin/`, `lib/` and
`res/`. Source packaging does not compile the compiler.

After publishing the versioned GitHub release, the separate authoritative
`pkg-catalog` owns the repository descriptor, executable launcher and
the `nodejs =26` package dependency. `m` installs and integrates released
artifacts. Neither `m` nor `pkg-catalog` contains this engine's source.

## Validation

```sh
sh tests/run.sh /path/to/m-checkout
```

The scenario uses a disposable clone of real standalone `m`, genuine
package integration and managed Node.js, and exercises public `m jsc`
JavaScript/CSS compilation. `tests/fixtures` is only local test data;
it is not a published package catalog.

The canonical compiler contract is
`rumiai-dev/specifications/rumiai-os/JSC.md`. This extracted source
derives from experimentally validated PoC 074 in
`rumiai-dev-PoCs/jsc-package-local-runtime@29bed6bc6cfafc96265c9b4d4b8b9e811b6aa6e9`;
the original `rumiai-os` and `rumiai-tests` remain untouched.
