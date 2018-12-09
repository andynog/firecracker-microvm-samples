# Firecracker's Micro Virtual Machines (microVMs) Samples

This repository contains examples of micro virtual machines (microVMs) that can be run using <a href="https://github.com/firecracker-microvm/firecracker" target="_blank">Firecracker</a>

##### Requirements

- All the samples were built, tested and run using __Ubuntu 18.04.1 LTS__ since you need KVM support in order to run Firecracker. For more information on supported Operating Systems (OS) and requirements please check the [Firecracker's FAQ page](https://github.com/firecracker-microvm/firecracker/blob/master/FAQ.md#what-operating-systems-are-supported-by-firecracker)

#### Getting Firecracker

In order to run these sample micro virtual machines, please download Firecracker or build it from source following the instructions below:

- Download the Firecracker binary following the <a href="https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md#getting-the-firecracker-binary" target="_blank">Quickstart Guide</a> or

- To build it from source, please follow Firecracker's <a href="https://github.com/firecracker-microvm/firecracker#getting-started" target="_blank">Getting Started Guide</a>

- **Save or copy the downloaded or built firecracker executable to this repository folder** in order to run the samples.


#### Micro Virtual Machine (Micro VM) samples

##### 

| Name      | Sample Folder           | Description  |
| ------------- |:-------------:| -----:|
| Echo Time     | [microvm-echo-time](./microvm-echo-time) | Minimal microVM (~7 MB rootfs) with a minimal Busybox guest operating system and a Rust executable that echo the current time|

#### Roadmap

- Provide additional samples that include networking, running a microservice, etc.

#### Disclaimer

These sample micro virtual machines are for demonstration purposes only. These are not production ready microVMs. The goal of making these microVMs available is to provide them as a learning resource for people interested in Firecracker technology.