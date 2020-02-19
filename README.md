# virtio_net-xdp-metadata-test

Test scripts for virtio_net XDP meta data support.

## Setup

```
./download_kernel.sh
./build_kernel.sh
```

## Test

* for receive_small()

```
./run-test.sh
```

* for receive_mergeable()

```
./run-test.sh --receive_mergeable
```

## TODO

* [ ] test for XDP_TX
* [ ] test for XDP_REDIRECT