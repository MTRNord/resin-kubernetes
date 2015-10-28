# Multi containers + Kubernetes on Resin.io

**THIS IS WORK IN PROGRESS**

The application starts a docker-in-docker instance and runs a Kubernetes kubelet.

Based on [abresas/multi-container](https://github.com/abresas/multi-container)
For docker in docker, check [jpetazzo/dind](https://github.com/jpetazzo/dind).

## Description

The [Kubernetes](https://kubernetes.io) project is a cluster management solution by Google. This repo contains a resin.io application that starts a docker-in-docker instance and then runs a Kubernetes node, capable of running arbitrary "pods", that is, groups of containers. Please refer to the [Kubernetes documentation](https://github.com/kubernetes/kubernetes/blob/master/docs/getting-started-guides/README.md) to better understand how Kubernetes works. 

To run this application, you will need to run a Kubernetes Master node (that serves the Kubernetes API) on another machine, and create a `MASTER_IP` [Environment Variable](http://docs.resin.io/#/pages/management/env-vars.md) for this device. After that you can use [kubectl](https://github.com/kubernetes/kubernetes/blob/master/docs/user-guide/kubectl/kubectl.md) to communicate with the Master and assign pods to your devices.

This repo uses a slightly [modified version](https://github.com/pcarranzav/kubernetes) of the Kubernetes hyperkube binary to accomodate for the fact that we are running on ARM devices and we are using `rce` (Resin.io's version of Docker, soon to be replaced by a regular Docker binary).

We also use Flannel to try to achieve the Kubernetes [networking model](https://github.com/kubernetes/kubernetes/blob/master/docs/design/networking.md), but this is not fully functional at the time. You should still be able to run a fully functional cluster over a local network.

## Behind the scenes
If you're interested in looking at how this app works, take a look at the [Dockerfile](./Dockerfile) and the [start.sh](./start.sh) script. This script basically initializes a docker (rce) daemon and then starts the Kubernetes node apps as follows:

```bash
/hyperkube kubelet --api_servers=http://${MASTER_IP}:8080 --v=1 \
	--address=0.0.0.0 --enable_server --docker-endpoint=$DOCKER_HOST &

/hyperkube proxy --master=http://${MASTER_IP}:8080 --v=1 &
```
