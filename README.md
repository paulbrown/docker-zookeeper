# Zookeeper on Kubernetes using a Pet Set

These are the things you need to run Zookeeper cluster on Kubernetes. 
It's based on Zookeeper version 3.5.x which is currently in alpha, 
but it's been pretty stable to date.


### Deployment

This example has been deployed and tested using a local Minikube setup.

Minikube is a tool that makes it easy to run Kubernetes locally. Minikube 
runs a single-node Kubernetes cluster inside a VM on your laptop for users 
looking to try out Kubernetes or develop with it day-to-day.

Minikube packages and configures a Linux VM, Docker and all Kubernetes 
components, optimized for local development. Minikube supports Kubernetes 
features such as:
- DNS
- NodePorts
- ConfigMaps and Secrets
- Dashboards

Deploying onto a Kubernetes cluster is fairly easy. There are example
kubernetes Service and Pet Set files in the [kube/](kube/) directory.

A Pet Set is a group of stateful pods that require a stronger notion 
of identity. The goal of Pet Set is to decouple this dependency by assigning
identities to individual instances of an application that are not anchored 
to the underlying physical infrastructure. 

A Pet Set requires there be {0..N-1} Pets. Each Pet has a deterministic name
(PetSetName-Ordinal), and a unique identity. Each Pet has at most one pod, 
and each Pet Set has at most one Pet with a given identity.

A Pet Set ensures that a specified number of “pets” with unique identities 
are running at any given time. The identity of a Pet is comprised of:
- a stable hostname, available in DNS
- an ordinal index
- stable storage: linked to the ordinal & hostname

Clustered software like Zookeeper suits itself well for a Pet Set 
as it relies on stable DNS names for discovery of peers for a quorum.

Please read Kubernetes Reference Documentation [here] 
(http://kubernetes.io/docs/user-guide/petset/) 
regarding limitations for the Pet Set alpha release.


#### Deploy Persistent Volumes

Pet Sets require the backing of some persistent storage. This command creates 
some storage volumes for each of the “pets”. Normally persistent volumes 
would be provisioned automatically in your cloud environment, however here we're just 
using local HostPath directories. 

```bash
$ kubectl create -f kube/zookeeper-volumes.yaml
```


#### Deploy Service
Each Pet Set must expose a headless service.

```bash
$ kubectl create -f kube/zookeeper-service.yaml
```


#### Deploy Pet Set
This command will create a Pet Set with 3 replicas.

```bash
$ kubectl create -f kube/zookeeper-petset.yaml
```


#### List the Pods

Get the pods:
```
$ kubectl get pods
NAME          READY     STATUS    RESTARTS   AGE
zookeeper-1   1/1       Running   0          9m
zookeeper-2   1/1       Running   0          8m
zookeeper-3   1/1       Running   0          7m
```

#### Test the Cluster

Now, let's see if our zookeeper cluster is healthy. First, we will set `/foo`
key to `bar`, then kill the Pod and try to get `/foo` from another zookeeper
instance:

```bash
$ kubectl exec -ti zookeeper-1 bash

[root@zookeeper-1]# /opt/zookeeper/bin/zkCli.sh
[zk: localhost:2181(CONNECTED) 1] create /foo bar
Created /foo
[zk: localhost:2181(CONNECTED) 2] get /foo
bar
```

Delete the pod we just used to set the `/foo` value:

```
$ kubectl delete zookeeper-1
$ kubectl exec -ti zookeeper-2 bash

[root@zookeeper-2]# /opt/zookeeper/bin/zkCli.sh
[zk: localhost:2181(CONNECTED) 0] get /foo
bar
```

Check that zookeeper-1 has come back up and contains `/foo` value:

```
$ kubectl exec -ti zookeeper-1 bash

[root@zookeeper-2]# /opt/zookeeper/bin/zkCli.sh
[zk: localhost:2181(CONNECTED) 0] get /foo
bar
```

This just shows that if one node dies, the cluster is still functioning and the
deleted pod will be re-created by the Pet Set with a consistent 
reliable naming convention.

### Known Caveats

So be aware that if you delete more than one pet (pod), you will lose the quorum.

