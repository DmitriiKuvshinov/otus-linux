## Создадим инфраструктуру через Vagrantfile
Поднимаем 2 машины: клиент и сервер

## Сконфигурируем 2 машинки через ansible
Выполянем: 
ansible-playbook files/web.yml --limit web
ansible-playbook files/elk.yml --limit log