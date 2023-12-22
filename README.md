# Bazel + SWC + paths resolution issue

## Summary

Demonstrates that SWC correctly resolves `jsc.paths` when running outside of Bazel, and then within Bazel resolves these paths to include sandboxs paths.

## Reproduction

1. Build to `dist/tsc` with `tsc`: `pnpm build-tsc`.
2. Build to `dist/swc` with `swc`: `pnpm build-pnpm`.
3. Build to `bazel-bin/` with `Bazel`: `pnpm build-bazel`.
4. Download [swc@v1.3.100](https://github.com/swc-project/swc/releases/tag/v1.3.100), and build in symlinked tmp dir: `./repro.sh`

# Issue

When built with Bazel (3), the resolved paths include the sandbox directory:

```
# bazel-bin/src/parent/index.js

import { name } from "../../../../../../../private/var/tmp/_bazel_jack.vincent/04548c3a2779b70cbf6368fff2f77038/sandbox/darwin-sandbox/12/execroot/__main__/src/parent/child";
export const parentName = name + "'s parent";
```

Outside Bazel, swc resolves the configured path to the relative path:

```
# dist/swc/parent/index.js

import { name } from "./child";
export const parentName = name + "'s parent";
```

Tsc does nothing with these imports, as they don't modify pure JS:

```
# dist/tsc/parent/index.js

import { name } from "@myorg/parent/child";
export const parentName = name + "'s parent";
```

Building with the swc cli in a symlinked tmp directory also works outside Bazel:

```
╰─❯ ./repro.sh
total 0
drwx------    4 jack.vincent  999066206   128 22 Dec 11:03 .
drwx------@ 244 jack.vincent  999066206  7808 22 Dec 11:03 ..
lrwxr-xr-x    1 jack.vincent  999066206    45 22 Dec 11:03 .swcrc -> /Users/jack.vincent/code/dump/swc_test/.swcrc
drwxr-xr-x    4 jack.vincent  999066206   128 22 Dec 11:03 src

./src:
total 0
drwxr-xr-x  4 jack.vincent  999066206  128 22 Dec 11:03 .
drwx------  4 jack.vincent  999066206  128 22 Dec 11:03 ..
lrwxr-xr-x  1 jack.vincent  999066206   51 22 Dec 11:03 index.ts -> /Users/jack.vincent/code/dump/swc_test/src/index.ts
drwxr-xr-x  4 jack.vincent  999066206  128 22 Dec 11:03 parent

./src/parent:
total 0
drwxr-xr-x  4 jack.vincent  999066206  128 22 Dec 11:03 .
drwxr-xr-x  4 jack.vincent  999066206  128 22 Dec 11:03 ..
drwxr-xr-x  3 jack.vincent  999066206   96 22 Dec 11:03 child
lrwxr-xr-x  1 jack.vincent  999066206   58 22 Dec 11:03 index.ts -> /Users/jack.vincent/code/dump/swc_test/src/parent/index.ts

./src/parent/child:
total 0
drwxr-xr-x  3 jack.vincent  999066206   96 22 Dec 11:03 .
drwxr-xr-x  4 jack.vincent  999066206  128 22 Dec 11:03 ..
lrwxr-xr-x  1 jack.vincent  999066206   64 22 Dec 11:03 index.ts -> /Users/jack.vincent/code/dump/swc_test/src/parent/child/index.ts
import { parentName } from "./parent";
import { name } from "./child";
```
