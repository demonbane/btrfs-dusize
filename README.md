# btrfs-dusize
## Installation
If you'd like to just check if `btrfs-dusize` will work on your system, you can do that without downloading anything by running the below command:
```
curl -s 'https://raw.githubusercontent.com/demonbane/btrfs-dusize/master/btrfs-dusize' | gawk -f -
```

To install `btrfs-dusize` more permanently, either download the script [directly](https://raw.githubusercontent.com/demonbane/btrfs-dusize/master/btrfs-dusize) or clone this repository.

## Usage
```
btrfs-dusize [VOLUME PATH]
```
```
$ btrfs-dusize /
Subvolume                                                 Total  Exclusive   ID
───────────────────────────────────────────────────────────────────────────────
@                                                      11.45GiB   73.33MiB  257
@home                                                   1.10GiB    1.10GiB  258
var/lib/docker/btrfs/subvolumes/433491a3877a[..]       65.23MiB    3.78MiB  489
var/lib/docker/btrfs/subvolumes/c68b2e34a297[..]       65.26MiB    3.80MiB  490
var/lib/docker/btrfs/subvolumes/383688b7f963[..]       65.78MiB    4.38MiB  491
@apt-snapshot-release-upgrade-bionic-2018-05-27_1[..]   8.37GiB  100.97MiB  522
@apt-snapshot-2018-05-30_00:31:48                       8.39GiB  236.75MiB  533
@apt-snapshot-2018-05-30_20:33:33                       7.61GiB   36.06MiB  535
───────────────────────────────────────────────────────────────────────────────
Exclusive Total:                                                   1.54GiB 
```
## Requirements
`btrfs-dusize` is written in pure AWK and requires GNU AWK (gawk) to run correctly. You must have btrfs quotas enabled in order to check usage. This is as simple as running `btrfs quota enable <path>` and waiting a few seconds for the initial scan to complete. After this you may run `btrfs-dusize` at any time to get a list of all existing subvolumes and snapshots and their exclusive usage.

## Features
If `tput` is available on your system, `btrfs-dusize` will use it to get the dimensions of your terminal and scale the output accordingly. Paths with very long components (like Docker subvolume IDs) will automatically be truncated. All other output will only be truncated if the terminal is too narrow to show all of the output data correct. (See above for examples)

## About
`btrfs-dusize` was inspired by and is based on the work of [Kyle Agronick](https://github.com/agronick) in [btrfs-size](https://github.com/agronick/btrfs-size) and [@nachoparker](https://github.com/nachoparker) in [btrfs-du](https://github.com/nachoparker/btrfs-du).

## Benchmarks
Since `btrfs-dusize` is just parsing and formatting data with a language dedicated to just that, it is quite fast. For comparison here is a benchmark run on my system with `btrfs-dusize`, `btrfs-du`, and `btrfs-size`:

```
$ time btrfs-dusize / > /dev/null

real    0m0.008s
user    0m0.008s
sys     0m0.001s

$ time btrfs-du / > /dev/null

real    0m0.173s
user    0m0.103s
sys     0m0.069s

$ time btrfs-size / > /dev/null

real    0m1.331s
user    0m1.275s
sys     0m0.368s
```
