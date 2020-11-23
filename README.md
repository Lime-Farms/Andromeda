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

## Playbooks
