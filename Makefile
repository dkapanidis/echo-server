# Well documented Makefile following: https://www.thapaliya.com/en/writings/well-documented-makefiles/
.DEFAULT_GOAL:=help

-include .env

.PHONY: docker.build publish go.build.arm64 go.build.amd64 install

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-z\.A-Z_0-9-]+:.*?##/ { printf "  \033[36m%-11s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

go.run: ## Runs app in dev mode (listens at :5678)
	go run ./

go.build: go.build.amd64 go.build.arm64 ## Build all binaries

go.build.arm64: ## Build arm64 binary
	GOARCH=arm64 go build -o echo-server.arm64 ./

go.build.amd64: ## Build amd64 binary
	GOARCH=amd64 go build -o echo-server.amd64 ./

docker.build: ## Build docker image
	docker buildx build --platform linux/amd64,linux/arm64 --output="type=image" --tag dkapanidis/echo-server .

docker.run.amd64: ## Run docker in arm64
	docker run --platform linux/amd64 -p 5678:5678 dkapanidis/echo-server

docker.run.arm64: ## Run docker in arm64
	docker run --platform linux/arm64 -p 5678:5678 dkapanidis/echo-server

docker.push: ## Push docker image to remote registry
	docker buildx build --platform linux/amd64,linux/arm64 --push --tag dkapanidis/echo-server .

docker.inspect: ## Inspect remote image
	docker buildx imagetools inspect dkapanidis/echo-server

clean: ## Clean generated files
	rm -f echo-server.*
