### Echo Time microVM

This is a simple microVM sample showing how to run firecracker with a minimal microVM with a very small root filesystem.

The goal of this sample is to show that a very small size rootfs (~7MB) can be created as a microVM that includes a simple executable program (static compiled Rust program).

This sample uses the Firecrackers **hello-vmlinux.bin** for the **kernel**

The root file system **echo-time-minvm-rootfs.ext4** uses a minimal **Busybox** base operating system and it also contains a **Rust** static compiled executable. 

The executable is very simple. It only displays the current time every three seconds.

The sample has scripts that could be re-used by other projects as the starting point to bootstrap microVMs. Also, the source code for the Rust executable is included so you can modify and create your own microVM. 

There are instructions below showing how to include a modified executable into the rootfs image file.

#### Running the microVM

#####1. Start Firecrakcer

**NOTE:** Before you run this microvm, please ensure you've followed the instructions on this repository's [README](../blob/master/README.md) on how to download or build Firecracker from source.

- Open a terminal window and run:

    ```./start-firecracker.sh```

**NOTE**: You will be prompted for the password when running this script since in order to run Firecracker you need KVM properly configured as that uses 'sudo' as per [Firecracker's Prerequisites section](https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md#prerequisites)

#####2. Run the microVM

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

```

#####3. Run the executable in the microVM

- Swtich back to the terminal window where you ran the script to start firecracker (step 1). You should see some messages from the vm booting up. Hit enter to get a shell prompt.

- Type microvm-echo-time in the shell prompt and hit Enter

    ```# echo-time```

- The program will output the current time every 3 seconds. 

```
# echo-time
Echo current date and time every 3 seconds...
To exit hit Ctrl-C...
The current UTC time is 08:19:23 PM
The current UTC time is 08:19:26 PM
The current UTC time is 08:19:29 PM
```

- Hit Ctrl+C to stop the program

- To stop the microVM and firecracker just close both terminal windows.

##### Rebuilding the rootfs and including a modified executable

**NOTE**
 - Please ensure you don't have any firecracker or microVM is running before proceeding with this step.
 - You will need a valid Rust installation in order to rebuild the executable. If you don't have Rust installed, please check the [Rust Install](https://www.rust-lang.org/tools/install) page to find more information on how to install it.

If you want to update the static compiled executable. Change the logic in the Rust program (/echo-time/src/main.rs) and run the script below. 

The script will re-compile the Rust executable using the right target, mount the rootfs file system and copy to new executable to the root filesystem, then unmount to rootfs. After the script is run you can run the microVM again and the updated executable will be in the microVM. 

Open a terminal and run:

```./rebuild-rootfs.sh```

**NOTE**: You will be prompted for the password when running this script since in order to mount the rootfs image properly it needs 'sudo'.

###### Resizing the rootfs image file
If you get errors about the lack of free space you might need to increase the size of the rootfs file. You can do that by running the commands:

```e2fsck -f ./echo-time-minvm-rootfs.ext4```

and then this command (if you want to increase it to 10 MB for example)

```resize2fs ./echo-time-minvm-rootfs.ext4 10M```

##### Logging

If you want to check the Firecracker's logging messages while you are running your microVM, open a terminal window and type:
 
 ```tail -f /tmp/firecracker-echo-time-log.fifo```