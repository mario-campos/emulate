# emulate

GitHub Actions for BSD.

```yaml
runs-on: macos-10.15
steps:
- name: Bootstrap OpenBSD 7.0
  uses: mario-campos/emulate@main
  with:
    operating-system: openbsd-7.0
- name: Build
  run: |
    git clone https://github.com/foo/bar.git
    cd bar && make
```

### Supported operating systems

| Supported OS | Input |
| ------------ | ----- |
| OpenBSD 7.0  |`openbsd-7.0`, `openbsd-latest` |

### Limitations
- :heavy_exclamation_mark: This Action is still very experimental :heavy_exclamation_mark:
- Only `run.shell=bash` steps are propogated to the guest at the moment. `run.shell=python` will run in the host.
- No support for Actions; just `run` steps.

### Development

The operating system images are defined in their respective directories and are all self-contained, meaning that they do not import any variables or configuration settings outside of their directories.

The images are built with Hashicorp Packer, as identified by the _.pkr.hcl_ file in each directory. This file controls the entire imaging process. The _Vagrantfile_ template file in the directory corresponds to the Vagrantfile that is bundled with the Box upon building. All other files are auxiliary.

Given that, you will need Hashicorp Packer, Hashicorp Vagrant, and Oracle VirtualBox installed locally.

#### Enable GUI

The _.pkr.hcl_ script in each directory is configured to run with `headless = true` by default. This setting is convenient for releases, but you should override it for debugging or supporting a new operating system. You can override this setting by passing the `headless` variable on the command line:

```shell
packer build -var headless=false openbsd-7.0
```
