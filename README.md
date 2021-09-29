# emulate

GitHub Actions for BSD.

```yaml
runs-on: ubuntu-latest
steps:
- name: Bootstrap DragonflyBSD 5.2.0
  uses: mario-campos/emulate@main
  with:
    operating-system: dragonflybsd-5.2.0
- name: Build
  run: |
    git clone https://github.com/foo/bar.git
    cd bar && make
```

### Supported operating systems

| Input                | Status             | Included packages   | Notes |
| -------------------- | :----------------: | ------------------- | ----- |
| `openbsd-6.9`        | :heavy_check_mark: | git sudo bash       | Default shell is `bash`. `doas` and `sudo` are both configured. |
| `freebsd-12.2`       | :heavy_check_mark: | git                 |       |
| `netbsd-9.2`         | :heavy_check_mark: | git ca-certificates |       |
| `netbsd-8.2`         | :heavy_check_mark: | git ca-certificates |       |
| `dragonflybsd-5.2.0` | :heavy_check_mark: | git                 |       |
| `hardenedbsd-13`     | :x:                |||

### Limitations
- :heavy_exclamation_mark: This Action is still very experimental :heavy_exclamation_mark:
- Be careful with sensative data inside the guest. The guests are deployed with untrusted/unverified images.
- Only `run.shell=bash` steps are propogated to the guest at the moment. `run.shell=python` will run in the host.
- No support for Actions; just `run` steps.
- Do not use this Action on non-ephemeral self-hosted runners. It is designed primarily for GitHub-hosted runners.
