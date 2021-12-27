# Package Managers

How to identify the right system package manager with chezmoi.

With [`.chezmoi.osRelease`](https://github.com/twpayne/chezmoi/blob/master/docs/REFERENCE.md#template-variables) we can get the info from `/etc/os-release` as dictionary to be used in templates. To detect Debian and Ubuntu, we can use the following template:

```
{{ if (eq .chezmoi.osRelease.id "debian" "ubuntu") -}}
# do debian/ubuntu stuff here
{{ end }}
```

## Systems and Package Managers

| Distribution | Os-release    | Package Manager | `update` command | `install` command |
| :----------- | :------------ | :-------------- | :--------------- | :---------------- |
| Debian       | `ID=debian`   | `apt-get`       | `update`         | `install -y`      |
| Ubuntu       | `ID=ubuntu`   | `apt-get`       | `update`         | `install -y`      |
| Alpine       | `ID=alpine`   | `apk`           | `update`         | `add`             |
| Arch Linux   | `ID=arch`     | `pacman`        | `-S`             | `-Sy --noconfirm` |
| CentOS       | `ID="centos"` | `yum`           | `check-update`   | `-y install`      |
| Fedora       | `ID=fedora`   | `dnf`           | `check-update`   | `-y install`      |

We need to use the right update / install command on each system and install packages which may have different names for each package manager, like [`chsh`](https://command-not-found.com/chsh)

## /etc/os-release

### Debian

```
> docker run debian cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

### Ubuntu

```
❯ docker run ubuntu cat /etc/os-release
NAME="Ubuntu"
VERSION="20.04.3 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.3 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
```

### Alpine

```
> docker run alpine cat /etc/os-release
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.15.0
PRETTY_NAME="Alpine Linux v3.15"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://bugs.alpinelinux.org/"
```

### Arch Linux

```
> docker run archlinux cat /etc/os-release
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://bugs.archlinux.org/"
LOGO=archlinux-logo
```

### CentOS

```
> docker run centos cat /etc/os-release
NAME="CentOS Linux"
VERSION="8"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="8"
PLATFORM_ID="platform:el8"
PRETTY_NAME="CentOS Linux 8"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:8"
HOME_URL="https://centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"
CENTOS_MANTISBT_PROJECT="CentOS-8"
CENTOS_MANTISBT_PROJECT_VERSION="8"
```

### Fedora

```
> docker run fedora cat /etc/os-release
NAME="Fedora Linux"
VERSION="35 (Container Image)"
ID=fedora
VERSION_ID=35
VERSION_CODENAME=""
PLATFORM_ID="platform:f35"
PRETTY_NAME="Fedora Linux 35 (Container Image)"
ANSI_COLOR="0;38;2;60;110;180"
LOGO=fedora-logo-icon
CPE_NAME="cpe:/o:fedoraproject:fedora:35"
HOME_URL="https://fedoraproject.org/"
DOCUMENTATION_URL="https://docs.fedoraproject.org/en-US/fedora/f35/system-administrators-guide/"
SUPPORT_URL="https://ask.fedoraproject.org/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"
REDHAT_BUGZILLA_PRODUCT="Fedora"
REDHAT_BUGZILLA_PRODUCT_VERSION=35
REDHAT_SUPPORT_PRODUCT="Fedora"
REDHAT_SUPPORT_PRODUCT_VERSION=35
PRIVACY_POLICY_URL="https://fedoraproject.org/wiki/Legal:PrivacyPolicy"
VARIANT="Container Image"
VARIANT_ID=container
```
