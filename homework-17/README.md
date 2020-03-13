# Home work. Сетевые пакеты. VLAN'ы. LACP. 
## Что было сделано
 Поднят стенд из предыдущего ДЗ
 Дописан вагрант-файл (добавлены дополнительные клиенты и серверы)
 Написана конфигурация для интерфейсов. Подготовлены плейбуки для ansible

## Как проверить
  Развернуть тестовый стенд:

  ```
  vagrant up testClient1
  vagrant up testClient2
  vagrant up testServer1
  vagrant up testServer2
  vagrant up inetRouter
  vagrant up centralRouter
  ```
  Применить плейбуки:
  ```
  ansible-playbook team.yml --limit inetRouter
  ansible-playbook team.yml --limit centralRouter
  ansible-playbook vlan.yml --limit centralRouter
  ```