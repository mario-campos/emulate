# emulate

GitHub Actions for BSD.

```yaml
runs-on: ubuntu-latest
steps:
- name: Bootstrap DragonflyBSD 5.2.0
  uses: mario-campos/emulate@v1
  with:
    operating-system: dragonflybsd-5.2.0
- name: Build
  run: |
    git clone https://github.com/foo/bar.git
    cd bar && make
```

### Supported operating systems

| OS tag               | Status             | Notes |
| -------------------- | ------------------ | ----- |
| `openbsd-6.9`        | :heavy_check_mark: | Default shell is `bash`. `doas` and `sudo` are both configured. |
| `freebsd-13.0`       | :heavy_check_mark: ||
| `netbsd-9.2`         | :heavy_check_mark: ||
| `dragonflybsd-5.2.0` | :heavy_check_mark: ||
| `hardenedbsd-13`     | :x:                ||

### Included software
- `git`

### Limitations
- :heavy_exclamation_mark: This Action is still very experimental :heavy_exclamation_mark:
- Be careful with sensative data inside the guest. The guests are deployed with untrusted/unverified images.
- Only `run.shell=bash` steps are propogated to the guest at the moment. `run.shell=python` will run in the host.
- No support for Actions; just `run` steps.
- Do not use this Action on non-ephemeral self-hosted runners. It is designed primarily for GitHub-hosted runners.
