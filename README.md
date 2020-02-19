# virtio_net-xdp-metadata-test

Test scripts for virtio_net XDP meta data support.

## Setup

* Install virtme

See https://github.com/amluto/virtme

* Download and build patched kernel.

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

* [x] tests for XDP_PASS
* [ ] tests for XDP_TX
* [ ] tests for XDP_REDIRECT
