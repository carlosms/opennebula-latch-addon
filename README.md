# OpenNebula Latch Addon

## Description

This add-on provides OpenNebula users with the possibility of using [Latch](https://latch.elevenpaths.com) for an extra layer of security. It includes an authentication driver, a CLI command, and a Sunstone tab.

Latch provides a mobile application to disable the OpenNebula account, adding protection in the event of credential theft. It also provides alert in case of unauthorized access attempt.

You can also see a video demo of this add-on here:

[ ![YouTube](https://github.com/carlosms/opennebula-latch-addon/blob/master/doc/youtube.png "YouTube video") ](http://youtu.be/ZiNVNfSJJoE "YouTube")

## Authors

* Carlos Martin Sanchez

## Compatibility

This add-on has been tested with OpenNebula 4.10. Other versions may be compatible.

The included Latch API SDK is for API version 0.9.

## Installation

### Get the code

Clone the git repository:

`$ git clone https://github.com/carlosms/opennebula-latch-addon.git`

### Run the install script

Execute the `install.sh` script. The options are:

```
Usage: install.sh [-u install_user] [-g install_group] [-d ONE_LOCATION] [-h]

-u: user that will run opennebula, defaults to user executing install.sh
-g: group of the user that will run opennebula, defaults to user
    executing install.sh
-d: target installation directory, if not defined it'd be root. Must be
    an absolute path.
-h: prints this help
```

In a typical installation, you should run it as root:

`# ./install.sh -u oneadmin -g oneadmin`

### Configure OpenNebula

First, add the new `latch` authentication driver to `oned.conf`:

```
# vim /etc/one/oned.conf
...
AUTH_MAD = [
    executable = "one_auth_mad",
    authn = "latch,ssh,x509,ldap,server_cipher,server_x509"
]
```

Then enable the Sunstone tab. To do so, add `latch` to the routes in `sunstone-server.conf`:

```
# vim /etc/one/sunstone-server.conf
...
:routes:
    - oneflow
    - vcenter
    - support
    - latch

```

Now add the new latch tab to the Sunstone view conf files. This includes the `sunstone-views.conf` available_tabs:

```
# vim /etc/one/sunstone-views.yaml
...
available_tabs:
    - dashboard-tab
    - system-tab
    - users-tab
    - groups-tab
    - acls-tab
    - vresources-tab
    - vms-tab
    - templates-tab
    - images-tab
    - files-tab
    - infra-tab
    - clusters-tab
    - hosts-tab
    - datastores-tab
    - vnets-tab
    - zones-tab
    - marketplace-tab
    - oneflow-dashboard
    - oneflow-services
    - oneflow-templates
    - provision-tab
    - latch-tab
    - support-tab
```

And enabled_tabs in both `admin.yaml` and `user.yaml` files:

```
# vim /etc/one/sunstone-views/admin.yaml
...
enabled_tabs:
    dashboard-tab: true
    system-tab: true
    users-tab: true
    groups-tab: true
    acls-tab: true
    vresources-tab: true
    vms-tab: true
    templates-tab: true
    images-tab: true
    files-tab: true
    infra-tab: true
    clusters-tab: true
    hosts-tab: true
    datastores-tab: true
    vnets-tab: true
    marketplace-tab: true
    oneflow-dashboard: true
    oneflow-services: true
    oneflow-templates: true
    support-tab: true
    latch-tab: true
    doc-tab: true
    community-tab: true
    enterprise-tab: true
    zones-tab: true
```

```
# vim /etc/one/sunstone-views/user.yaml
...
enabled_tabs:
    dashboard-tab: true
    system-tab: false
    users-tab: false
    groups-tab: false
    acls-tab: false
    vresources-tab: true
    vms-tab: true
    templates-tab: true
    images-tab: true
    files-tab: true
    infra-tab: true
    clusters-tab: false
    hosts-tab: false
    datastores-tab: true
    vnets-tab: true
    marketplace-tab: true
    oneflow-dashboard: true
    oneflow-services: true
    oneflow-templates: true
    support-tab: false
    latch-tab: true
    doc-tab: false
    community-tab: false
    enterprise-tab: false
```

### Configure Latch

You need to create a Latch Developer Account, and create a new Application for your OpenNebula deployment in the developer portal. This application does not need to have any Operations defined.

Write down the Latch Application ID and Secret, and put them in the `latch_auth.conf` file:

```
# vim /etc/one/auth/latch_auth.conf

# Latch Application credentials
:app_id: 'xxxxx'
:app_secret: 'xxxxx'
```

Head on to the Latch page for more information: https://latch.elevenpaths.com/www/getting.html

### Restart OpenNebula

Now you must restart the OpenNebula core and Sunstone services.

```
# service opennebula restart
# service opennebula-sunstone restart
```

## Usage

### Configure the User view

The Latch integration can be configured through the CLI, or via Sunstone. For Sunstone, it is only available in the `admin` and `user` Sunstone views.

Read more about Sunstone views in the [OpenNebula documentation](http://docs.opennebula.org/4.10/administration/sunstone_gui/suns_views.html).

### Configure the User driver

In order to use the Latch functionality, the OpenNebula user account must have the `latch` authentication driver set. You can create new users directly with this driver set, or use the `oneuser chauth` command to update existing users.

```
$ oneuser create uname pass --driver latch
ID: 4
```

```
$ oneuser chauth uname latch
```

### Pair the Latch account

To pair your OpenNebula account with Latch, generate a new code in your smartphone application and use it in the Latch menu entry in Sunstone. You can also perform this action with the CLI:

```
$ onelatch pair uname xxxxxx
```

## Considerations

### Session expiration time

You may want to change the `SESSION_EXPIRATION_TIME` in oned.conf to a lower value.

### SHA1 passwords

With the Latch driver, passwords are stored in plain text by default. Plain text passwords cannot be seen by any other user in the system, but if the database is compromised... well, you'll put Latch 2 step authentication to a real test.

You can change this behaviour in `latch_auth.conf` to use sha1 instead.

Because this is an external authentication driver, this change has the following implications:

* New user accounts must provide the sha1 password. This is easy with the CLI, but it can't be done automatically from the Sunstone wizard:

```
$ oneuser create uname pass --driver latch --sha1
```

* New passwords must also be provided in sha1. End users can't do this easily from Sunstone, although the CLI has an option for it:

```
$ oneuser passwd uname pass --sha1
```
