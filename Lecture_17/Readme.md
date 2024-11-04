`docker-compose ps`

![Результат роботи скрипта]( Screenshots/docker_compose_ps.PNG)

`docker network ls`

![Результат роботи скрипта]( Screenshots/docker_network_ls.PNG)


`docker volume ls`

![Результат роботи скрипта]( Screenshots/docker_volume_ls.PNG)

`docker exec -it <ad9749203643b4bb2ed7c1d8a1147c4408b9a24fdfe35450b1d30ab1e2f91ff7> psql -U postgres`

![Результат роботи скрипта]( Screenshots/docker_exec.PNG)

`docker-compose up -d --scale web=3`

Для успішного створення однакових сервісів треба прописати
`ports:
- "0:80"`

![Результат роботи скрипта]( Screenshots/web=5.PNG)



