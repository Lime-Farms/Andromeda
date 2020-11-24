# Andromeda

## About

Ansible playbooks used to setup, maintain, and lime-ify servers.

## Roles

### `init`

A very simple role for initializing a server: add some sane defaults, some
general configuration files, and ensure commonly needed packages are installed.

### `ssh`

Configure and harden the SSH server. This role should obtain an A+ from
[SSH Audit](https://www.sshaudit.com/).

### `user`

Setup regular and administrator users.

This role has the following default variables:

  * username: name for the new user
  * group: primary group to add the user to
  * comment: optional comment to describe the user
  * shell: login shell for the user
  * admin: flag to make the user an administrator
  * sshkey: SSH public key required for signing into the server

### `acme`

A role specialized for requesting and installing a certificate over
[ACME](https://tools.ietf.org/html/rfc8555) using the dehydrated client and
Cloudflare DNS authentication.

This role has the following default variables:

  * acme_endpoint: server to request a certificate from
  * subject_name: primary name for the certificate
  * alternate_names: array of names to add to the SAN
  * renew_email: email to direct renewal notices to

## Playbooks
