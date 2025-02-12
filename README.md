# emulate

GitHub Actions for BSD.

```yaml
runs-on: ubuntu-latest
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
| OpenBSD 7.6   |`openbsd-7.6`, `openbsd-latest`  |
| FreeBSD 14.2  |`freebsd-14.2`, `freebsd-latest` |
| NetBSD 10.1   |`netbsd-10.1`, `netbsd-latest`   |

### Limitations
- :heavy_exclamation_mark: This Action is still very experimental :heavy_exclamation_mark:
- Only `run.shell=bash` steps are propogated to the guest at the moment. `run.shell=python` will run in the host.
- No support for Actions; just `run` steps.
- GitHub-hosted-runner environment variables will be propogated to the BSD guest.