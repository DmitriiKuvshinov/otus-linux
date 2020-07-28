# Postfix Dovecot

## Как поднять
Выполнить vagrant up
Создать 2 пользователей с паролями на сервере

## Как проверить
Через веб-интерфейс войти: http://localhost/webmail под одним из созданных пользователей
С хост-машины выполнить: 
```
telnet 127.0.0.1 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 virtual.domain.tld ESMTP Postfix
EHLO virtual.domain.tld
250-virtual.domain.tld
250-PIPELINING
250-SIZE 10240000
250-VRFY
250-ETRN
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 DSN
mail from: <mailfrom@domain.tld>
250 2.1.0 Ok
rcpt to: <mail@domain.tld>
250 2.1.5 Ok
data    
354 End data with <CR><LF>.<CR><LF>
From: test <mailfrom@domain.tld>
rcpt to: <mail@domain.tld>
data
From: test <mailfrom@domain.tld>
To: test <mail@domain.tld>
Subject: test
Content-Type: text/plain
est
.
250 2.0.0 Ok: queued as BD3EB64921
quit
221 2.0.0 Bye
Connection closed by foreign host.
```