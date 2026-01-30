.PHONY: build build-all clean run

BINARY_NAME=ocd-installer
BUILD_DIR=../../dist/installer

build:
	go build -o $(BINARY_NAME) main.go

build-all: clean
	mkdir -p $(BUILD_DIR)
	
	# Windows
	GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-windows-x64.exe main.go
	
	# macOS Intel
	GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-mac-x64 main.go
	
	# macOS Apple Silicon  
	GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-mac-arm64 main.go
	
	# Linux x64
	GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-linux-x64 main.go
	
	# Linux ARM64
	GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 main.go
	
	# Linux ARMv7
	GOOS=linux GOARCH=arm GOARM=7 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME)-linux-armhf main.go
	
	@echo "✓ Built all binaries in $(BUILD_DIR)"

clean:
	rm -f $(BINARY_NAME)
	rm -rf $(BUILD_DIR)

run:
	go run main.go

deps:
	go mod download
	go mod tidy
