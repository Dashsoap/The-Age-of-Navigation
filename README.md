# AON-MUD
This is a project built for the game: the age of navigation

### circom
snark to verify coordinates
```
circom circuit.circom --r1cs --wasm --sym
snarkjs powersoftau new bn128 12 m.ptau
snarkjs powersoftau contribute m.ptau m_final.ptau
snarkjs powersoftau prepare phase2 m_final.ptau powersoftau.ptau
snarkjs groth16 setup circuit.r1cs
snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="aon"
snarkjs zkey export verificationkey circuit_0001.zkey verification_key.json
snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol

cd circuit_js/ && node generate_witness.js circuit.wasm ../input.json ../witness.wtns
cd .. && snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json
snarkjs generatecall
```

### contracts
mud contracts

faucet:
```
pnpm mud faucet --address <Contract Address>
```

deploy:
```
pnpm mud deploy --chainSpec </pathTo/chainSpec.json> --deployerPrivateKey <Private Key>
```

### abis
```
cp -r ~/aon-mud/packages/circuits/ circom
cp -r ~/aon-mud/packages/contracts/abi/ abi
cp -r ~/aon-mud/packages/contracts/types/ types
```
