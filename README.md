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

### XDP_PASS

* for receive_small()

```
./run-test.sh
```

* for receive_mergeable()

```
./run-test.sh --receive_mergeable
```

### XDP_TX

* start a vm

```
./run-vm.sh
```

* setup guest in the vm

```
./setup_guest.sh
```

* setup host

```
./setup_host.sh
```

* check the result of ping to guest from host

```
ping 10.0.1.2
```

## TODO

* [x] tests for XDP_PASS
* [x] tests for XDP_TX
* [ ] tests for XDP_REDIRECT
