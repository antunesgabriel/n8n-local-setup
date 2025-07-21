build-images:
	docker compose down -v  && docker compose up -d --build

stop-containers:	
	docker compose stop

start-containers:
	docker compose start
