-include .env

.PHONY: all test depoly


build: 
	@echo "building......"
	@forge build
	@echo "Done"


test:; forge test

 

install: ; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install transmissions11/solmate@v6 --no-commit


depoly-sepolia: ; forge script script/DepolyRaffle.s.sol:DepolyRaffle --rpc-url ${SEPOLIA_RPC_URL} --account myaccount --broadcast --verify  --etherscan-api-key ${ETHERSCAN_API_KEY} -vvv