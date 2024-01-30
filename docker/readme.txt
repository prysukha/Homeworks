docker build -t 070387/homework-flask-0.0.2 . # собираем docker image
docker container ls # проверяем доступные (созданные) образы
docker container run -d -p 3000:5000 070387/homework-flask-0.0.2  #запускаем контейнер
docker container stop #указать начальный id контейнера, например bbbf