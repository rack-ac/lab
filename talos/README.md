# Talos Cluster Management

## Bootstrap a new cluster

### 1. Create the cluster config files

Create a directory for the cluster and add the required files, using `talos/main` as a reference:

```
talos/<cluster>/
  machineconfig.yaml.j2        # base machine config template (1Password refs use talos-<cluster>)
  controlplane/
    schematic.yaml             # Talos factory schematic (kernel args + extensions)
    controlplane.yaml          # network config shared across all controlplane nodes
    <node>.yaml                # per-node patch (hostname, disk serial, labels)
```

Each `<node>.yaml` needs at minimum:

```yaml
---
machine:
  type: controlplane
  install:
    diskSelector:
      serial: "<disk serial>"
---
apiVersion: v1alpha1
kind: HostnameConfig
hostname: <node>
```

The `machineconfig.yaml.j2` references secrets via `op://kubernetes/talos-<cluster>/FIELD`. Update the item name to match your cluster.

### 2. Register the cluster in Taskfile.yaml

Add the cluster name to the `CLUSTERS` list in `.taskfiles/onepassword/Taskfile.yaml`:

```yaml
vars:
  CLUSTERS:
    - main
    - <cluster>
```

### 3. Generate secrets and talosconfig

```sh
task bootstrap:init CLUSTER=<cluster>
```

This will:
- Generate Talos secrets and upload them to 1Password (`talos-<cluster>` item in the `kubernetes` vault)
- Generate `talos/<cluster>/talosconfig`
- Push the talosconfig to 1Password and write it to `~/.talos/config`

### 4. Boot the nodes into Talos

Boot each node from a Talos ISO. The ISO can be generated from the cluster schematic:

```sh
task talos:generate-iso CLUSTER=<cluster> NODE=<node> VERSION=v1.x.x
```

Assign static IPs to each node at boot time — you will need these in the next step.

### 5. Apply config and bootstrap Kubernetes

```sh
task talos:init-nodes CLUSTER=<cluster> ENDPOINTS="<ip1> <ip2> <ip3>"
```

If you are starting with a single node:

```sh
task talos:init-nodes CLUSTER=<cluster> ENDPOINTS="<ip1>" NODES="<node>"
```

This will:
- Set the node endpoints and names in the talosconfig
- Apply the machine config to each node
- Bootstrap the Kubernetes control plane (ETCD)
- Fetch the kubeconfig and push everything to 1Password

---

## Add a node to an existing cluster

### 1. Create the node config file

Add a per-node patch file at `talos/<cluster>/controlplane/<node>.yaml` (or `worker/<node>.yaml` for a worker):

```yaml
---
machine:
  type: controlplane
  install:
    diskSelector:
      serial: "<disk serial>"
---
apiVersion: v1alpha1
kind: HostnameConfig
hostname: <node>
```

### 2. Boot the node into Talos

Boot from a Talos ISO and assign it a static IP.

### 3. Register the endpoint and apply config

```sh
task talos:add-node CLUSTER=<cluster> NODE=<node> ENDPOINT=<ip>
```

This will:
- Append the new IP to the endpoints in the talosconfig
- Add the node name to the talosconfig nodes list
- Apply the machine config to the new node

The node will join the cluster automatically via the existing ETCD.
