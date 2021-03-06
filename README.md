# emulate

GitHub Actions for BSD.

```yaml
runs-on: macos-10.15
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

### Limitations
- :heavy_exclamation_mark: This Action is still very experimental :heavy_exclamation_mark:
- Only `run.shell=bash` steps are propogated to the guest at the moment. `run.shell=python` will run in the host.
- No support for Actions; just `run` steps.
