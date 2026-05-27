---
name: diagrams
description: Generate polished architecture and flow diagrams from text using D2. Use when creating architecture diagrams, flowcharts, decision trees, sequence flows, ERDs, or any text-to-diagram work where Mermaid's auto-routing produces amateur output. Triggers on "make a diagram", "diagram this", "draw the architecture", "flowchart", or any d2/diagram request.
---

# Diagrams

Default to D2 over Mermaid. ELK layout, source in `.d2` files, render to SVG (canonical) and PNG (review).

## Prereqs

`d2` 0.7+ installed (`brew install d2` on macOS). First PNG render downloads bundled Chromium (~1 MiB, ~1 min) - subsequent are fast.

Do not install TALA. Evaluation mode renders a giant "UNLICENSED COPY" watermark. Licensed TALA wasn't clearly better than ELK on architecture-shaped diagrams during testing.

## Defaults

```bash
D2_LAYOUT=elk d2 src/foo.d2 out/foo.svg
D2_LAYOUT=elk d2 src/foo.d2 out/foo.png   # PNG for inline preview
```

Or in the `.d2` source so the file carries its own config:

```d2
vars: {
  d2-config: {
    layout: elk
    pad: 20
  }
}
```

Layout choice rationale: dagre breaks on container-heavy diagrams (container titles overlap each other). ELK respects `direction:` directives and produces clean orthogonal routing.

## Output paths

Put sources and renders under the project that uses them:

```
projects/<name>/src/01-<diagram>.d2
projects/<name>/out/01-<diagram>.svg
projects/<name>/out/01-<diagram>.png
```

Commit the `.d2` source and `.svg` output (text-diffable). PNG is for inline preview; gitignore it.

## Gotchas

- An in-canvas `title: { shape: text }` shape gets clipped by surrounding containers. Either omit the title (the document title metadata is enough) or place the title node outside the main container at the top level.
- Container nesting + sibling external nodes (e.g., a control-plane node sitting outside the cluster container) renders best in ELK.
- Use `direction: right` for left-to-right pipelines. ELK respects it; dagre+TALA may not.
- Edge labels overlap when too many edges converge on one shape. Spread the labels by positioning text (`{position: 0.3, side: top}`) or by routing through an intermediate hub node.

## Syntax cheatsheet

### Shapes & connections

```d2
client -> server -> db: query
server -> cache
a <-> b              # bidirectional
a -- b               # undirected
a -> b: "label"      # labeled edge

# Explicit shapes
node1: {shape: cylinder}   # rectangle (default), cylinder, oval, diamond,
                           # hexagon, cloud, document, page, queue, package,
                           # circle, parallelogram, step, stored_data, person
```

### Containers (nesting)

```d2
cluster: Cluster {
  control: Control Plane
  workers: Workers {
    w1: Worker 1
    w2: Worker 2
  }
  control -> workers
}

client -> cluster.control
```

### Classes (reusable styles - use for consistency)

```d2
classes: {
  external: {
    style.fill: "#E8F0FE"
    style.stroke: "#1565c0"
  }
  storage: {
    shape: cylinder
    style.fill: "#FFF4E5"
  }
  decision: {
    shape: diamond
    style.fill: "#fff3e0"
  }
}

client: Client {class: external}
store: Object Store {class: storage}
check: Valid? {class: decision}
```

### Icons

D2 accepts any SVG URL. Terrastruct hosts a free pack at `https://icons.terrastruct.com/`:

```d2
client: {
  icon: https://icons.terrastruct.com/essentials/user.svg
}

lb: {
  icon: https://icons.terrastruct.com/aws/Networking%20%26%20Content%20Delivery/Elastic%20Load%20Balancing.svg
}
```

Categories: `aws/`, `gcp/`, `azure/`, `tech/`, `essentials/`, `dev/`. Browse at https://icons.terrastruct.com.

### Variables

```d2
vars: {
  primary: "#4a90d9"
}

box.style.fill: ${primary}
```

### SQL tables (for ERD)

```d2
users: {
  shape: sql_table
  id: int {constraint: primary_key}
  email: varchar {constraint: unique}
}

orders: {
  shape: sql_table
  id: int {constraint: primary_key}
  user_id: int {constraint: foreign_key}
}

users.id <-> orders.user_id
```

## Common patterns

### System architecture (left-to-right)

```d2
direction: right

vars.d2-config.layout: elk

client: Customer
edge: Ingress {shape: hexagon}

services: Services {
  api: API
  auth: Auth
  api -> auth: validate
}

data: Data Layer {
  db: Postgres {shape: cylinder}
  cache: Redis {shape: cylinder}
}

client -> edge -> services.api
services.api -> data.db
services.api -> data.cache
```

### Sequence-like flow (numbered)

```d2
direction: right

user: User
fe: Frontend
api: API
db: Database

user -> fe: 1. click
fe -> api: 2. POST
api -> db: 3. INSERT
db -> api: 4. ok
api -> fe: 5. 200
fe -> user: 6. success
```

### Decision tree with colored edges

```d2
classes: {
  decision: {shape: diamond; style.fill: "#fff3e0"}
  action:   {style.fill: "#e3f2fd"; style.border-radius: 8}
  terminal: {shape: oval; style.fill: "#e8f5e9"}
}

start: Start {class: terminal}
check: Valid request? {class: decision}
accept: Process {class: action}
reject: Reject {class: action}
done: Done {class: terminal}

start -> check
check -> accept: Yes {style.stroke: "#2e7d32"}
check -> reject: No  {style.stroke: "#c62828"}
accept -> done
reject -> done
```

## Workflow

1. Write `.d2` source in `projects/<name>/src/`.
2. Render: `D2_LAYOUT=elk d2 src/foo.d2 out/foo.svg out/foo.png` (D2 accepts multiple outputs).
3. View the PNG with `Read` to verify (multimodal). Iterate on the source until layout is clean.
4. Commit the `.d2` source and the `.svg`. PNG is gitignored.
5. For active iteration, use `d2 --watch --browser src/foo.d2` and let the live preview drive the work.

## Useful flags

| Flag | Purpose |
|------|---------|
| `-l elk` / `D2_LAYOUT=elk` | Pick layout engine |
| `-w, --watch` | Auto-rerender on save |
| `--browser` | Open live preview (with `--watch`) |
| `-t N` | Theme ID (run `d2 themes` for the list) |
| `--dark-theme N` | Dark mode theme |
| `--sketch` | Hand-drawn aesthetic |
| `--scale 2` | 2x output resolution |
| `--pad 40` | Padding around diagram in pixels |
| `--layout` (no arg) | List installed layout engines |

## When NOT to use D2

- Embedding directly in a GitHub README - GitHub renders Mermaid natively, not D2. Either commit the rendered SVG alongside, or use Mermaid for that specific file.
- Tiny inline doc diagrams (3-4 boxes) - Mermaid in the markdown is fine; D2 source + render step is overkill.
- Sequence diagrams with rich syntax (activations, async messages) - Mermaid's sequence syntax is purpose-built; D2 fakes it with edges.

Everything else: D2.
