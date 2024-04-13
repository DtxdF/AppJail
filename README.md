<p align="center">
    <img src="assets/img/Slogan.png" width="60%" height="auto" />
</p>

----

# AppJail

AppJail is an open-source BSD-3 licensed framework entirely written in `sh(1)` and C to create isolated, portable and easy to deploy environments using FreeBSD jails that behaves like an application.

Its goals are to simplify life for sysadmins and developers by providing a unified interface that automates the jail workflow by combining the base FreeBSD tools.

*AppJail offers simple ways to do complex things.*

## Features

* Easy to use.
* Parallel startup (Healthcheckers, Jails & NAT).
* UFS and ZFS support.
* RACCT/RCTL support.
* NAT support.
* Port expose - network port forwarding into jail.
* IPv4 and IPv6 support.
* DHCP and SLAAC support.
* Virtual networks - A jail can be on several virtual networks at the same time.
* Bridge support.
* VNET support
* Deploy your applications much easier using Makejail!
* Netgraph support.
* LinuxJails support.
* Supports thin and thick jails.
* TinyJails - Experimental feature to create a very stripped down jail that is very useful to distribute.
* Startup order control - Using priorities and the boot flag makes management much easier.
* Jail dependency support.
* Initscripts - Make your jails interactive!
* Backup your jails using tarballs or raw images (ZFS only) with a single command.
* Modular structure - each command is a unique file that has its own responsibility in AppJail. This makes AppJail maintenance much easier.
* Table interface - many commands have a table-like interface, which is very familiar to many sysadmin tools.
* No databases - each configuration is separated in each entity (networks, jails, etc.) which makes maintenance much easier.
* Healthcheckers - Monitor your jails and make sure they are healthy!
* Images - Your jail in a single file!
* DEVFS support - Dynamic device management!
* ...

## Documentation

[AppJail Documentation](https://appjail.readthedocs.io/en/latest)

## Comparing AppJail

[How does AppJail compare to other FreeBSD jail frameworks?](https://appjail.readthedocs.io/en/latest/compare/)

## Support

[Need help using AppJail?](https://github.com/DtxdF/AppJail/wiki#support)

## Design decisions

**Characters Allowed**:

* Jail Name, Network Name, Custom Stage and Volume Name: Although jail names can use any character (except `.`), AppJail does not use any possible character. Valid regex is `^[a-zA-Z0-9_][a-zA-Z0-9_-]*$`.
* Interface Name: For interface names, the regex is `^[a-zA-Z0-9_][a-zA-Z0-9_.]*$`.
* JNG: For `jng`, the regex is `^[a-zA-Z_]+[a-zA-Z0-9_]*$` and for its links the regex is `^[0-9a-zA-Z_]+$`.

**AppJail tries to not modify the host**:

Such as making changes to `rc.conf(5)`, `sysctl.conf(5)`, the firewall configuration file, etc. It is preferable that the user is aware of such changes, this simplifies a lot.

**AppJail tries not to be interactive**

**AppJail tries not to play with jails created not by itself**

**AppJail tries not to automate everything**:

Instead of using one command to do a lot of work, it is preferable to combine small commands. A perfect example is `appjail makejail` which leaves the responsibility to the main commands.

**AppJail is not focused on building software**:

There are very interesting projects like `poudriere` or `synth` that can also create a custom repository. Use that custom repository in a jail created by AppJail to install your ports.

## TODO

- [ ] Add support for `ipfw` and `ipfilter`.
- [x] Although Makejails can be retrieved anywhere by the methods described in `INCLUDE`, a centralized repository to easily retrieve generic Makejails is useful. This can be done on Github or Gitlab. (See https://github.com/AppJail-makejails).
- [x] Create Makejails for applications. It is a difficult job to do alone, but with many people it is feasible. (Done using the centralized repository, of course this is in progress anyway).
- [ ] rc scripts to start resource limitation rules, nat for jails and to expose ports. `appjail quick` and `appjail-config` do this job, but it can be useful to spend less time starting/stopping jails.
- [X] Implement a supervisor. (Done using a similar way to supervise jails and their services named `Healthcheckers`).
- [x] Add option to `appjail config` to check if the parameters of a template are valid for `jail(8)`. (Done with the new tool, `appjail-config`)
- [ ] Implement all `jail(8)` parameters in `appjail quick`.
- [ ] The `jng` script is useful, but AppJail must create the Netgraph nodes in the same way as bridges and epairs.
- [ ] Man pages (**WIP**):
  * [X] **appjail(1)**
  * [X] **appjail-ajspec(5)**
  * [X] **appjail-apply(1)**
  * [X] **appjail-checkOld(1)**
  * [X] **appjail-cmd(1)**
  * [X] **appjail-cpuset(1)**
  * [X] **appjail.conf(5)**
  * [X] **appjail-config(1)**
  * [X] **appjail-deleteOld(1)**
  * [ ] **appjail-devfs(1)**
  * [X] **appjail-disable(1)**
  * [X] **appjail-dns(8)**
  * [X] **appjail-enable(1)**
  * [X] **appjail-enabled(1)**
  * [X] **appjail-etcupdate(1)**
  * [X] **appjail-expose(1)**
  * [X] **appjail-fetch(1)**
  * [X] **appjail-fstab(1)**
  * [ ] **appjail-healthcheck(1)**
  * [X] **appjail-help(1)**
  * [X] **appjail-image(1)**
  * [X] **appjail-initscript(5)**
  * [X] **appjail-jail(1)**
  * [X] **appjail-limits(1)**
  * [X] **appjail-login(1)**
  * [X] **appjail-logs(1)**
  * [X] **appjail-makejail(1)**
  * [ ] **appjail-makejail(5)**
  * [ ] **appjail-nat(1)**:
  * [ ] **appjail-network(1)**
  * [X] **appjail-pkg(1)**
  * [X] **appjail-quick(1)**
  * [X] **appjail-restart(1)**
  * [X] **appjail-rstop(1)**
  * [X] **appjail-run(1)**
  * [X] **appjail-service(1)**
  * [X] **appjail-start(1)**
  * [X] **appjail-startup(1)**
  * [X] **appjail-status(1)**
  * [X] **appjail-stop(1)**
  * [X] **appjail-sysrc(1)**
  * [X] **appjail-template(5)**
  * [X] **appjail-tutorial(7)**
  * [ ] **appjail-update(1)**
  * [ ] **appjail-upgrade(1)**
  * [X] **appjail-usage(1)**
  * [X] **appjail-user(8)**
  * [X] **appjail-volume(1)**
  * [X] **appjail-version(1)**
  * [X] **appjail-zfs(1)**
 
## Contributing

If you have found a bug, have an idea or need help, use the [issue tracker](https://github.com/DtxdF/AppJail/issues/new). Of course, PRs are welcome.
