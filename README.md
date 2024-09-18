# echo-server
Echo Server

### Quick Setup

Type `make` to get help:

```sh
$ make

Usage:
  make

Targets:
  help         Display this help
  all          Build all binaries
  build.arm64  Build arm64 binary
  build.amd64  Build amd64 binary
  run          Runs app in dev mode (listens at :5678)
  clean        Clean generated files
```

Build all binaries:

```sh
$ make all
GOOS=linux GOARCH=amd64 go build -o echo-server.amd64 ./
GOOS=linux GOARCH=arm64 go build -o echo-server.arm64 ./
```

Build all docker images

```sh
$ docker buildx create --use
$ make docker.build
docker buildx build --platform linux/amd64,linux/arm64 --tag dkapanidis/echo-server .
...
```

### Preparations

To prepare a Kubernetes multi-arch cluster on GCP:

- Go to "Kubernetes Engine: Clusters"
  - Create Cluster "Estandar"
    - Basic Info:
      - Zone: "europe-west4-a" (supports T2A)
    - Node Groups:
      - amd64:
        - Nodes:
          - E2
      - arm64:
        - Nodes:
          - T2A (arm based)
    - Network
      - Public cluster

Once cluster is up, see the nodes and their arch:

```sh
$ kubectl get nodes -L kubernetes.io/arch
NAME                                      STATUS   ROLES    AGE     VERSION               ARCH
gke-multi-arch-demo-amd64-f291be89-5pgn   Ready    <none>   5m36s   v1.30.3-gke.1639000   amd64
gke-multi-arch-demo-arm64-f2c51f67-s3pf   Ready    <none>   5m36s   v1.30.3-gke.1639000   arm64
```

Now check the arm64 node that has the following taint:

```yaml
  taints:
  - effect: NoSchedule
    key: kubernetes.io/arch
    value: arm64
```

To schedule the workload on the arm64 node:

```yaml
  tolerations:
    - key: "kubernetes.io/arch"
      operator: "Equal"
      value: "arm64"
      effect: "NoSchedule"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                  - arm64
```

Check the pod is running on the arm64 node:

```sh
$ kubectl get pod -o wide
NAME                           READY   STATUS    RESTARTS   AGE   IP           NODE                                      NOMINATED NODE   READINESS GATES
echo-server-744c8cc9dc-4vdfm   1/1     Running   0          86s   10.84.0.13   gke-multi-arch-demo-arm64-f2c51f67-s3pf   <none>           <none>
```

