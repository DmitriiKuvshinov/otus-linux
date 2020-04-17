# OSPF
## Как запуститься
Выполнить vagrant up.
Будет поднят стенд из 3 ВМ:
vm1:
- eth1: 192.168.12.10/24 - net12
- eth2: 192.168.16.10/24 - net16
- eth3: 10.1.0.1/24 - AR1

vm2:
- eth1: 192.168.12.9/24 - net12
- eth2: 192.168.20.10/24 - net20
- eth3: 10.2.0.1/24 - AR2

vm3:
- eth1: 192.168.16.9/24 - net16
- eth2: 192.168.20.9/24 - net20
- eth3: 10.3.0.1/24 - AR3

## Задание 1
Выполнить:
- ansible-playbook task1-vm1.yml
- ansible-playbook task1-vm2.yml
- ansible-playbook task1-vm3.yml

Ansible сконфигурирует ВМ, используя конфиги из директории  task1

## Задание 2
Выполнить:
- ansible-playbook task2-vm1.yml

Ansible сконфигурирует ВМ, используя конфиги из директории  task2

## Задание 3
Выполнить:
- ansible-playbook task3-vm3.yml

Ansible сконфигурирует ВМ, используя конфиги из директории  task3