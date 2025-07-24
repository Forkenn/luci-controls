# luci-controls
The "LuCI Controls" module adds the ability to send remote restart or shutdown commands to Unix devices on the local network via SSH. *For the most part this is a personal project :-)*

# Requirements
For OpenWrt versions 23.05 and above the **luci-lua-runtime** package is required.

The devices to be managed must be in local network, have public keys installed for SSH access and access to the **reboot** and **shutdown** commands. Security is described in the Recommendations section.

**The private SSH key must be in dropbear format.**

The OpenWrt device must have **/usr/lib/lua/luci/controller** and **/usr/lib/lua/luci/view** directories. If these directories do not exist you need to install the **luci-lua-runtime** package. The device must have the **/etc/config** directory. The unavailability of this directory probably means that the module will not work on your system.

# Installation
If the OpenWrt version is 23.05 or higher you need to install the dependencies:
```shell script
opkg update
opkg install luci-lua-runtime
```

After that, the module can be installed:
```shell script
git clone https://github.com/Forkenn/luci-controls.git
cd luci-controls
chmod +x install.sh
./install.sh
luci-reload
```
After installation, the control panel is accessible via the LuCI navigation bar ("Local Controls" -> "State Managment") or by address **.../admin/control-page/state-manager**.

# Configuration
The configuration is available in JSON format in the **/etc/config/luci-controls.json** file. The file contents are an array of devices:
```javascript
[
    {
        "name": "Device _",
        "ip": "192.168.0._",
        "user": "...",
        "key": "/home/username/..."
    },
    ...
]
```
Device parameters include:
* name - Device name for web-interface
* ip - Local IP address for device control via SSH
* user - Name of the user on the device who has access to the commands
* key - Private SSH key for auth on device

# Recommendations
**Usage of this module is allowed only on the home network.**

To ensure better security of controlled devices, it is recommended to create a user with access to only two commands: reboot and shutdown.

It is also recommended to restrict the user's access to the shell using [ForceCommand](https://man.openbsd.org/ssh_config) in the SSH configuration and restrict password login.

Using [PAM](https://en.wikipedia.org/wiki/Linux_PAM) it is recommended to restrict the login to the user from the local device.

# Notes
* In recent versions of OpenWRT apparently UCI support in lua has been broken, so configuration is still done via JSON.
* Using ubus is not possible with all devices, and using the HTTP API or RPC significantly complicates the project so the module temporarily uses *os.execute* functions which is unsafe but the author is still working on this problem.

# Feedback
Please report issues on the [GitHub project](https://github.com/Forkenn/luci-controls) when you suspect something.