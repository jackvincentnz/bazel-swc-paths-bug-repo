# Bazel + SWC + paths resolution issue

## Summary

Demonstrates that SWC correctly resolves `jsc.paths` when running outside of Bazel, and then within Bazel resolves these paths to include sandboxs paths.

## Reproduction

1. Build to `dist/tsc` with `tsc`: `pnpm build-tsc`.
2. Build to `dist/swc` with `swc`: `pnpm build-pnpm`.
3. Build to `bazel-bin/` with `Bazel`: `pnpm build-bazel`.

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
