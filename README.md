# emulate

GitHub Actions for BSD.

```yaml
runs-on: macos-12
steps:
- name: Bootstrap OpenBSD
  uses: mario-campos/emulate@v1
  with:
    operating-system: openbsd-latest
- name: Build
  run: |
    git clone https://github.com/foo/bar.git
    cd bar && make
```

### Supported operating systems

| Supported OS  | Input |
| ------------- | ----- |
| OpenBSD 7.1   |`openbsd-7.1`, `openbsd-latest`  |
| OpenBSD 7.0   |`openbsd-7.0`                    |
| FreeBSD 13.0  |`freebsd-13.0`, `freebsd-latest` |
| NetBSD 9.2    |`netbsd-9.2`, `netbsd-latest`    |

### Upgrading from `macos-10.15`

The `macos-10.15` runners have now been deprecated and will soon no longer be an option. The good news is that there is an easy fix: change your workflow files to use the newer `macos-12` runner! The bad news is that you will need to change your workflow files. Sorry for the inconvenience.

### Limitations
- :heavy_exclamation_mark: This Action is still very experimental :heavy_exclamation_mark:
- Only `run.shell=bash` steps are propogated to the guest at the moment. `run.shell=python` will run in the host.
- No support for Actions; just `run` steps.
