# A User mangement solution with ansible 

User accounts on the server need to be managed. In order to do this Ansible can be used. 
This folder contains 

This is not an enterprise grade solution, the assumption is that very few users actually need to be managed.

The advantage of using Ansible for user management: its declarative, fairly secure and it provides an overview which users have access to your server.


## What is Ansible?

[Ansible](https://www.ansible.com/) is an IT automation tool.
It executes tasks (for example creating users) specified in a `playbook.yaml` on a group of machines specified in an `inventory.yaml`.

## User mangement with ansible

### Specify which users need to be managed

Specify which users need to be managed in `encrypted_vars.yaml` and change the secret hashing salt value.

```
users:
  - username: user1
    password: my_password
    state: present
  - username: user2
    password: password
    state: present
  - username: user_that_should_be_absent
    password: passwd
    state: absent
secret_salt: secret
```

Encrypt this file with `ansible-vault` and choose a password:

```
ansible-vault encrypt encrypted_vars.yaml
```

In order to edit the file:

```
ansible-vault edit encrypted_vars.yaml
```

View the contents of the file:

```
ansible-vault view encrypted_vars.yaml
```

### Add your server to the inventory

In `inventory.yaml` change the ip address to the address or domain name of your server. 

```
analyseserver:
  hosts:
    <ip-address>
```

### Create accounts on the server

Create the accounts on the server as follows:

```
ansible-playbook -i inventory.yaml -u <username-admin-account> create_users_playbook.yaml --ask-vault-password
```

Whenever you need to update or add user accounts, change the values in `encrypted_vars.yaml` and run the playbook again.
