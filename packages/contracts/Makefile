.PHONY: docker-build docker-run docker-clean start stop

# 构建 Docker 镜像
start-node:
	cd ./deployment/node && docker-compose up -d

start-snapshot:
	cd ./deployment/snapshot && docker-compose up -d

start-mud-snapshot:
	cd ./deployment/mudtestnet && docker-compose up -d

start-mud-faucet:
	cd ./deployment/mudfaucet && docker-compose up -d

stop-node:
	cd ./deployment/node && docker-compose down

stop-snapshot:
	cd ./deployment/snapshot && docker-compose down

stop-mud-snapshot:
	cd ./deployment/mudtestnet && docker-compose down

stop-mud-faucet:
	cd ./deployment/mudfaucet && docker-compose down