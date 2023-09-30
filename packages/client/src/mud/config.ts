import { SetupContractConfig } from "@latticexyz/std-client";
import { getBurnerWallet } from "./getBurnerWallet";

const params = new URLSearchParams(window.location.search);

// https://emojimon.vercel.app/?worldAddress=0xB44F2C8E358Aeb8D2Be9Cb6e5693d9A861D34712&initialBlockNumber=7847366&rpc=https://follower.testnet-chain.linfra.xyz&wsRpc=wss://follower.testnet-chain.linfra.xyz&chainId=4242&faucet=https://faucet.testnet-mud-services.linfra.xyz

export const config: SetupContractConfig & { faucetServiceUrl?: string } = {
  clock: {
    period: 1000,
    initialTime: 0,
    syncInterval: 5000,
  },
  provider: {
    jsonRpcUrl:
      params.get("rpc") ?? "https://follower.testnet-chain.linfra.xyz",
    wsRpcUrl: params.get("wsRpc") ?? "wss://follower.testnet-chain.linfra.xyz",
    chainId: Number(params.get("chainId")) || 4242,
  },
  privateKey: getBurnerWallet().privateKey,
  chainId: Number(params.get("chainId")) || 4242,
  snapshotServiceUrl:
    params.get("snapshot") ??
    "https://ecs-snapshot.testnet-mud-services.linfra.xyz",
  faucetServiceUrl:
    params.get("faucet") ?? "https://faucet.testnet-mud-services.linfra.xyz",
  initialBlockNumber: Number(params.get("initialBlockNumber")) || 7847366,
  worldAddress:
    params.get("worldAddress") ?? "0xB44F2C8E358Aeb8D2Be9Cb6e5693d9A861D34712",
  devMode: params.get("dev") === "true",
};
