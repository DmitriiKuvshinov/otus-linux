# Простая защита от ДДОС

##  Проверяем

```
docker run -p 80:80 kuvshinov/ddos

dmitrii@Dmitrijs-MacBook-Pro otus-linux % curl http://localhost/otus.txt           
<html>
<head><title>302 Found</title></head>
<body>
<center><h1>302 Found</h1></center>
<hr><center>nginx/1.17.10</center>
</body>
</html>
dmitrii@Dmitrijs-MacBook-Pro otus-linux % curl -b check=1 http://localhost/otus.txt
kuvshinov/ddos
```
