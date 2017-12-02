# How to connect to the Truck chain

Aura Proof-of-Authority network with two validator nodes.

### Get Parity:

- One-Line-Installer: `$ bash <(curl https://get.parity.io -kL)`
- Releases: https://github.com/paritytech/parity/releases
- Instructions: https://github.com/paritytech/parity/wiki/Setup

### Run Parity:

- From terminal: `parity --chain truckchain.json --reserved-peers reserved.txt`

Both the json and the txt are available in this repository.

    2017-12-02 15:45:55  Starting Parity/v1.8.3-beta-b49c44a19-20171114/x86_64-linux-gnu/rustc1.21.0
    2017-12-02 15:45:55  Configured for TruckChain using AuthorityRound engine
    2017-12-02 15:46:32     0/25 peers   8 KiB chain 7 KiB db 0 bytes queue 448 bytes sync  RPC:  0 conn,  0 req/s,   0 µs
    2017-12-02 15:47:32     1/25 peers   8 KiB chain 7 KiB db 0 bytes queue 10 KiB sync  RPC:  0 conn,  0 req/s,   0 µs
    2017-12-02 15:48:00  Imported #1 a102…d99c (0 txs, 0.00 Mgas, 1.00 ms, 0.56 KiB)
    2017-12-02 15:48:02     1/25 peers   8 KiB chain 8 KiB db 0 bytes queue 10 KiB sync  RPC:  0 conn,  0 req/s,   0 µs
    2017-12-02 15:48:32     2/25 peers   8 KiB chain 8 KiB db 0 bytes queue 10 KiB sync  RPC:  0 conn,  0 req/s,   0 µs
    2017-12-02 15:48:45  Imported #2 bf02…75f8 (0 txs, 0.00 Mgas, 0.33 ms, 0.56 KiB)
    2017-12-02 15:49:32     2/25 peers   8 KiB chain 8 KiB db 0 bytes queue 10 KiB sync  RPC:  0 conn,  0 req/s,   0 µs
    2017-12-02 15:50:02     2/25 peers   8 KiB chain 8 KiB db 0 bytes queue 10 KiB sync  RPC:  0 conn,  0 req/s,   0 µs
    2017-12-02 15:50:29  Imported #3 fb58…f509 (0 txs, 0.00 Mgas, 0.81 ms, 0.56 KiB)

- Chain Explorer: http://truckchain.5chdn.co/#/ 
- Github: https://github.com/TruckChain/explorer
