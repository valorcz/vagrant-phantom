# vagrant-phantom Installation Notes

## Introduction

Splunk Phantom can be installed locally for an easier development, or just to
prevent some issues with dev instances elsewhere. And although it's supported,
the only two ways you can install it are:
  * using OVA VM image file,
  * installation `tar` ball.

Both are quite big in size (5 GB+) and have some benefits and drawbacks. One
biggest issue is with customization and reproducibility of such a setup.

## Deployment Tricks

While the deployment is now automated, there are a few hints and tricks
I'd like to share with you.

### Specifying Phantom Version

This relies heavily on the prepared repo structure, but in case someone
did the heavy lifting, you can specify a concrete Phantom version by
setting up a `PHANTOM_VERSION` variable prior to running `vagrant up`:

```bash
PHANTOM_VERSION=4.10.6.61906-1 vagrant up
```
For PowerShell terminal, use following command:
```powershell
$Env:PHANTOM_VERSION='4.10.6.61906-1' | vagrant up
```

**If you don't specify any Phantom version, the provisioning script chooses the
latest available one.**

If you specify a version that's not available in the setup, you'll be 
notified and the provisioning process will stop, letting you know the available
versions:

```bash
    default: Vagrant enforced Phantom version: 4.10.6
    default: [*] Phantom version to be installed: 4.10.6
    default: [!] Requested Phantom version isn't available in the cache.
    default: [!] Available versions:
    default: [!]    5.2.1.78411-1
    default: [!]    4.10.6.61906-1
```

### Preserving Phantom Configuration

Well, I wasn't super happy about the way Phantom stores its configuration.

It's a combination of files and DB records, so tracking how a particular
setting could be preset was quite painful.

My current recommendation is to setup your clean instance the way you
want and like, even with credentials, private URLs, basically anything
that makes your dev setup useful.

Then, `vagrant ssh` into the Phantom instance, and use this:

```bash
sudo phenv ibackup --backup --config-only
```

It'll create a backup in a form of CSV files and some extra archives,
which, if needed, could be analyzed, tweaked, adjusted...

Also, it'll **print out the path** where the backup is located,
so that you can download it from the VM and use for future, automated
provisioning.

### Configuration Restore

If you copy the backup into `/vagrant/backup/` folder, or to a `backup`
folder of this setup, my provisioning script will find the latest backup
and automatically restores it during the provisioning phase.

*Not great, not terrible.*

#### Configuration Adjustments Note

Btw, it's possible to take the backup `.tgz` file and remove parts
you don't consider necessary for your setup :) 

## References

Links and resources I used while creating this repository.

  * [Phantom 4.10 RPM base repo](https://repo.phantom.us/phantom/4.10/base/)
  * [Phantom Backup Restore docs](https://docs.splunk.com/Documentation/Phantom/4.10.7/Admin/Restorefromabackup)
