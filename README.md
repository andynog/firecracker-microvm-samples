# Firecracker's Micro Virtual Machines (microVMs) Samples

This repository contains examples of micro virtual machines (microVMs) that can be used with <a href="https://github.com/firecracker-microvm/firecracker" target="_blank">Firecracker</a>

#### Requirements

- All the samples were built, tested and run using __Ubuntu 18.04.1 LTS__ since you need KVM support in order to run Firecracker. For more information on supported Operating Systems (OS) and requirements please check the [Firecracker's FAQ page](https://github.com/firecracker-microvm/firecracker/blob/master/FAQ.md#what-operating-systems-are-supported-by-firecracker)

#### Getting Firecracker

In order to run these sample microVMs, please download Firecracker or build it from source following the instructions below:

- Download the Firecracker binary following the <a href="https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md#getting-the-firecracker-binary" target="_blank">Quickstart Guide</a> or

- To build it from source, please follow Firecracker's <a href="https://github.com/firecracker-microvm/firecracker#getting-started" target="_blank">Getting Started Guide</a>

- **Save or copy the downloaded or built firecracker executable to this repository folder** in order to run the samples.


#### Micro Virtual Machines (microVMs) samples

##### 

| Name      | Sample Folder           | Description  |
| ------------- |:-------------:| -----------:|
| Echo Time     | [microvm-echo-time](./microvm-echo-time) | Minimal microVM (~10 MB rootfs) with a minimal Busybox guest OS and a Rust executable that echo the current time|
| Web Server     | [microvm-web-server](./microvm-web-server) | microVM minimal guest OS (Alpine Linux) with network enabled and a simple web server|

#### Roadmap

- Provide additional samples that include:
 
    - ~~Minimal microVM~~ (Done => Echo Time sample)
    - ~~Networking~~ (Done => Web Server sample)
    - microVM Metadata Service (mmds) (TBD)
    - ssh (TBD)

#### Disclaimer

These sample micro virtual machines (microVMs) are for demonstration purposes only. These are not production ready microVMs. 

The samples have been tested but there's no guarantee they will work on different machines and configurations. Some troubleshooting tips are provided in case issues occur. Please use them with caution or setup an experimental environment to test these samples since some samples make modifications in the host machine (e.g. networking, etc.)

The goal of making these microVMs available is to provide a learning resource for people interested in [Firecracker's virtual machine manager (vmm)](https://firecracker-microvm.github.io/) technology.