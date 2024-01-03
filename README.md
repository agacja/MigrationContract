# Migration Contract
### Optimized  smart contract for transferring ERC20/ERC721

## Contracts

```
src
    ├─ UniqlyMigration -> Bulk transfers written in inline assembly for ERC20, ERC721.
Using mappings in order to track totalERC20Migrated, totalERC721Migrated on chain.
 ```

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

