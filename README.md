# jsc

Independent JavaScript/CSS source compiler in the technical `m` ecosystem.

`jsc` compiles declarative ordered JSON source descriptors to standalone
JavaScript namespace bundles or concatenated CSS. It does not own project
selection, dependency discovery, deployment, or installation.

The compiler is distributed through the `pkg` subsystem, with managed
Node.js as its execution dependency. It is not needed to bootstrap `m`.
Implementation and operational manuals remain inside the package's
materialized root, not the global `m/lib/sys` tree.

Canonical behavior: `rumiai-dev/specifications/rumiai-os/JSC.md`.
