## Echo Time microVM

**NOTE:** This sample has been tested running on a __Ubuntu 18.04.1 LTS__ machine (not virtualized).

This is a simple microVM sample showing how to run a minimal microVM in Firecracker.

The goal of this sample is to show that a very small size rootfs can be created as a microVM that includes a simple executable program (static compiled Rust program).

This sample uses the **hello-vmlinux.bin kernel** specified by Firecracker in its [Running Firecracker](https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md#running-firecracker) section

The root file system **echo-time-minvm-rootfs.ext4** uses a minimal **Busybox** base operating system and it also contains a **Rust** static compiled executable. 

The executable is very simple. It only displays the current time every three seconds.

This sample has scripts that could be re-used by other projects as the starting point to bootstrap microVMs. Also, the source code for the Rust executable is included so you can modify and create your own microVM. 

There are instructions below showing how to include a modified executable into the rootfs image file.

### Running the microVM

#### 1. Start Firecrakcer

**NOTE:** Before you run this microVM, please ensure you've followed the instructions on this repository's [README](../README.md) on how to download or build Firecracker from source.

- Open a terminal window and run:

    ```./start-firecracker.sh```

**NOTE**: You will be prompted for the password when running this script since in order to run Firecracker you need KVM properly configured as that uses 'sudo' as per [Firecracker's Prerequisites section](https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md#prerequisites) instructions.

#### 2. Run the microVM

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

#### 3. Run the executable in the microVM

- Switch back to the terminal window where you ran the script to start firecracker (step 1). You should see some messages from the vm booting up. Hit enter to get a shell prompt.

- Type *echo-time* in the shell prompt and hit Enter

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

- Hit Ctrl+C to stop the program (This is not working, to stop just close the terminal. See [issue](https://github.com/andynog/firecracker-microvm-samples/issues/1))

- To stop the microVM and firecracker just close both terminal windows.

### Rebuilding the rootfs and including a modified Rust executable

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

```e2fsck -f ./images/echo-time-minvm-rootfs.ext4```

and then run this command (if you want to increase it to 20 MB for example)

```resize2fs ./images/echo-time-minvm-rootfs.ext4 20M```