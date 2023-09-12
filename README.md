A simplified version of thirdweb's AirdropERC721 contract used for migrating your NFTs to a new wallet. Works with thirdweb gasless options

Usage (Node.js)
1. With gasless (very useful when you want to rescue the NFTs that are stuck in your drained wallets)
```js
try {
  const _tokenAddress = process.env.TOKEN_ADDRESS!; //
  const migrateContractAddress = process.env.MIGRATE_CONTRACT!; // migrate erc721
  const _recipient = process.env.NEW_WALLET!; // new wallet that will receive the rescued nfts
  
  const thirdwebSdk = ThirdwebSDK.fromPrivateKey(process.env.LEAKED_PRIVATE_KEY!, 'polygon', {
    gasless: {
      openzeppelin: {
        relayerUrl: process.env.OZ_GASLESS_POLYGON!,
      },
    },
    secretKey: process.env.THIRDWEB_SECRET_KEY,
  });
  const _tokenOwner = process.env.DRAINED_WALLET_ADDRESS!; // leakedWalletAddress
  const [migrateContract, nftContract] = await Promise.all([
    thirdwebSdk.getContract(migrateContractAddress),
    thirdwebSdk.getContract(_tokenAddress),
  ]);
  
  // You need to approve the Migrate contract to send the NFTs on your behalf
  const isApproved = await nftContract.erc721.isApproved(_tokenOwner, migrateContractAddress);
  if (!isApproved) await nftContract.erc721.setApprovalForAll(migrateContractAddress, true);
  else console.log('contract is approved to send nfts');
  
  const owners = await nftContract.erc721.getAllOwners();
  const allTokenIds = owners.filter((item) => item.owner === _tokenOwner).map((item) => item.tokenId);
  // Due to block space limit, we only send a few hundred per batch (tweak the number til it works for u)
  const magicNumber = 10;
  const _tokenIds = allTokenIds.length <= magicNumber ? allTokenIds : allTokenIds.slice(0, magicNumber);

  // Start migrating
  const data = await migrateContract.call('migrate', [_tokenAddress, _tokenOwner, _recipient, _tokenIds]);
  return res.send(data);
  return res.send(_tokenIds);
} catch (err) {
  console.log(err);
  return res.send(err);
}
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
