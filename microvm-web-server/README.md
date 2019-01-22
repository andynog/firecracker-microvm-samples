## Web Server microVM

**NOTE:** This sample has been tested running on a __Ubuntu 18.04.1 LTS__ machine (not virtualized) and __Firecracker v0.13.0__

This is a sample showing how to run a "Hello World" web server (built with Rust) in a microVM running on top of Firecracker.

The goal of this sample is to demonstrate the right networking configuration needed in the host and guest machines so they can communicate (in this case via the web server).

This sample uses the **hello-vmlinux.bin kernel** specified by Firecracker in its [Running Firecracker](https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md#running-firecracker) section

The root file system **web-server-rootfs.ext4** uses Alpine Linux as the base operating system and also includes a simple executable program (A static compiled Rust program. Source code is provided).

The executable is very simple. It is a simple web server that displays a message __'MicroVM says => Hello World!'__. It was build using Rust's [Gotham](https://gotham.rs/) web framework

This sample has scripts that could be re-used by other projects as the starting point to bootstrap microVMs with network enabled. Also, the source code for the Rust executable is included so you can modify and create your own web server microVM. 

There are instructions below showing how to include a modified executable into the rootfs image file.

### Running the microVM

Make sure you are running these commands from the __microvm-web-server__ folder. Every time you open a terminal prompt please ensure you're in the correct folder before running the scripts.

`cd microvm-web-server`

#### 1. Start Firecrakcer

**NOTE:** Before you run this microVM, please ensure you've followed the instructions on this repository's [README](../README.md) on how to download or build Firecracker from source.

- Open a terminal window and run:

    ```./start-firecracker.sh```

**NOTE:** You will be prompted for the password when running this script since in order to run Firecracker you need KVM properly configured as that uses 'sudo' as per [Firecracker's Prerequisites section](https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md#prerequisites) instructions.

#### 2. Run the microVM

*** __IMPORTANT__ ***

This script modifies `iptables` rules on your machine. If you have existing rules please check the [Firecracker's Network Setup guide](https://github.com/firecracker-microvm/firecracker/blob/master/docs/network-setup.md) with information on how to save them 

You will be prompted for the password when running this script since in order to setup the network in the host machine properly you need to sudo.

- Open another terminal window and run:

    ```./run-microvm.sh```

- Once you run the script above the terminal should output a few 204 HTTP Response messages. This means firecracker successfully accepted the requests made to its API.

    ```
    HTTP/1.1 204 No Content
    Date: Sun, 09 Dec 2018 18:11:16 GMT
    
    HTTP/1.1 204 No Content
    Date: Sun, 09 Dec 2018 18:11:16 GMT
    
    HTTP/1.1 204 No Content
    Date: Sun, 09 Dec 2018 18:11:16 GMT
    
    HTTP/1.1 204 No Content
    Date: Sun, 09 Dec 2018 18:11:16 GMT
    
    HTTP/1.1 204 No Content
    Date: Sun, 09 Dec 2018 18:11:16 GMT
    
    HTTP/1.1 204 No Content
    Date: Sun, 09 Dec 2018 18:11:16 GMT
    
    ```

#### 3. Run the executable in the microVM

- Switch back to the terminal window where you ran the script to start firecracker (step 1). You should see some messages from the vm booting up.

- Login into the microVM. Use (Login: root / Password: root)

- Finish configuring the network in the microVM. In the microVM terminal prompt, type:

    `# ip addr add 172.16.0.2/24 dev eth0`
    
    `# ip route add default via 172.16.0.1 dev eth0`
    
- Type *web-server* in the shell prompt and hit Enter

    `# web-server`
    
    You should see a message showing that the web server is listening for connections:
    
    ```
    Listening for requests at http://172.16.0.2:8080
    [   44.245064] random: web-server: uninitialized urandom read (16 bytes read)
    ```
    
- Access the web server from the host machine. In your host machine, open a browser and type the following URL:

    `http://172.16.0.2:8080/`
    
    If everything was configured properly you should see a message saying __MicroVM says => Hello World!__
    
    [](browser.png)
    

- To stop the microVM and firecracker hit CTRL+C to stop the web server and type in the terminal:
    
    `# reboot`


#### Testing web server performance

If you are curious about performance, after the whole setup and once the microVM can be reached from the host machine you can perform some load testing to see that even though this is just a simple web server (built with Rust) and running on top of Firecracker (also build on Rust), it is really performant. 

If you have [ab - Apache HTTP server benchmarking tool](https://httpd.apache.org/docs/2.4/programs/ab.html) utility installed you can try to submit thousands of requests:

For example, making 50K requests with 100 concurrent requests at a time:

`ab -c 100 -n 50000 http://172.16.0.2:8080/`

On my machine (Intel(R) Core(TM) i5-8250U CPU @ 1.60GHz) it took 6.8 seconds with almost 7400 reqs/sec with 99% of the requests completed in 16ms  and the max CPU for Firecracker process during execution was only 12% (this might vary on different machines and also there's no network latency in this case since everything was running locally but still impressive). 

```
~$ ab -c 100 -n 50000 http://172.16.0.2:8080/
This is ApacheBench, Version 2.3 <$Revision: 1807734 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 172.16.0.2 (be patient)
Completed 5000 requests
Completed 10000 requests
Completed 15000 requests
Completed 20000 requests
Completed 25000 requests
Completed 30000 requests
Completed 35000 requests
Completed 40000 requests
Completed 45000 requests
Completed 50000 requests
Finished 50000 requests


Server Software:        
Server Hostname:        172.16.0.2
Server Port:            8080

Document Path:          /
Document Length:        28 bytes

Concurrency Level:      100
Time taken for tests:   6.817 seconds
Complete requests:      50000
Failed requests:        0
Total transferred:      9100000 bytes
HTML transferred:       1400000 bytes
Requests per second:    7335.12 [#/sec] (mean)
Time per request:       13.633 [ms] (mean)
Time per request:       0.136 [ms] (mean, across all concurrent requests)
Transfer rate:          1303.70 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       5
Processing:     2   14   1.0     13      22
Waiting:        2   14   1.0     13      21
Total:          3   14   1.0     13      22
WARNING: The median and mean for the total time are not within a normal deviation
        These results are probably not that reliable.

Percentage of the requests served within a certain time (ms)
  50%     13
  66%     14
  75%     14
  80%     14
  90%     15
  95%     16
  98%     16
  99%     16
 100%     22 (longest request)

```

### Troubleshooting networking issues

If you can't reach the web server from the host machine. Please try this commands to help you determine what might be causing the issue.

##### On the host machine:

- In your host machine open a terminal prompt and type:

    `ip addr show tap0`

    You should see an entry for the tap, something similar to this:
    
    ```
    4: tap0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
        link/ether 86:81:02:cf:ce:b9 brd ff:ff:ff:ff:ff:ff
    ```

- In the same terminal prompt, type:

    `ip route show`

    You should see an entry similar to the one below (you might see additional entries but don't worry about those)

    `172.16.0.0/24 dev tap0 proto kernel scope link src 172.16.0.1`

##### On the guest machine (microVM)

- In your guest machine (microVM) open a terminal prompt and type:

    `ip addr show`

    You should see something similar to this (note that in the guest the network interface is eth0 and not tap0):

    ```
    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether aa:fc:00:00:00:01 brd ff:ff:ff:ff:ff:ff
        inet 172.16.0.2/24 scope global eth0
           valid_lft forever preferred_lft forever
        inet6 fe80::a8fc:ff:fe00:1/64 scope link 
           valid_lft forever preferred_lft forever

    ```
    
- In the same terminal prompt, type:

    `ip route show`

    You should see an entry similar to the one below:

    `172.16.0.0/24 dev eth0 proto kernel scope link src 172.16.0.2`
    
***NOTE***: If you don't see these outputs please make sure you configured the guest networking as specified in step 3.

### Additional tasks

#### Cleaning up the network tap

If you want to delete the tap0 network, open a terminal prompt and execute the command below:

`sudo ip link del tap0`

#### Downloading image files (kernel and rootfs)

If you want to download updates for the image files you can use the script below.


- Open a terminal window and run:

```./sudo download-images.sh```

You should see two files __'hello-vmlinux.bin'__ and __'web-server-rootfs.ext4'__ (the rootfs file is based on the xenial.rootfs.ext4 provided by AWS, it is just renamed after downloaded). You will need to rebuild the ext4 volume again as per instructions below in order to have the executable in the image.

#### Rebuilding the rootfs and including a modified Rust executable

**NOTE:**
 - Please ensure you don't have any firecracker or microVM running before proceeding with this step.
 - You will need a valid Rust installation in order to rebuild the executable. If you don't have Rust installed, please check the [Rust Install](https://www.rust-lang.org/tools/install) page to find more information on how to install it.
 - Once Rust is installed, add the target:
 ```rustup target add x86_64-unknown-linux-musl```
 
If you want to update the static compiled executable. Change the logic in the [Rust program](./echo-time/src/main.rs) and run the script below. 

The script will re-compile the Rust executable using the right build target (x86_64-unknown-linux-musl), mount the rootfs file system and copy to new executable to the root filesystem, then unmount to rootfs. After the script is run you can run the microVM again and the updated executable will be copied to the microVM and the image will be unmounted. Once the script has finished you can run the microVM again (step 1).g 

- Open a terminal and run:

    ```./rebuild-rootfs.sh```

**NOTE**: You will be prompted for the password when running this script since in order to mount the rootfs image properly it needs 'sudo'.

#### Resizing the rootfs image file

If you get errors about the lack of free space you might need to increase the size of the rootfs file. You can do that by running the commands:

```e2fsck -f ./echo-time-minvm-rootfs.ext4```

and then run this command (if you want to increase it to 20 MB for example)

```resize2fs ./echo-time-minvm-rootfs.ext4 20M```