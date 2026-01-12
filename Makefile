# Makefile for BlueSavings

.PHONY: help test build deploy clean format lint coverage

help:
	@echo "BlueSavings Makefile Commands:"
	@echo "  make test       - Run all tests"
	@echo "  make build      - Build contracts"
	@echo "  make deploy     - Deploy to testnet"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make format     - Format code"
	@echo "  make lint       - Run linter"
	@echo "  make coverage   - Generate coverage report"

test:
	forge test -vv

build:
	forge build

deploy:
	forge script script/Deploy.s.sol:DeployScript --rpc-url base_sepolia --broadcast

clean:
	forge clean

format:
	forge fmt

lint:
	solhint 'src/**/*.sol' 'test/**/*.sol'

coverage:
	forge coverage

gas:
	forge test --gas-report

snapshot:
	forge snapshot
