Using GitHub Actions is a great option for deploying code from a GitHub repository to Pantheon if you want to add additional Continous Integration workflow in your setup. 


With this Github action, you can:

  - Deploy you repo with
    - Whole code repo
	- To a nested docroot `/web` path (TODO)
	- A specific theme, plugin, or any other directory by specifying the LOCAL_PATH and REMOTE_PATH options. (TODO)
  - Post deploy options:
	- Clear cache (TODO)
	- Auto commit and deploy to `TEST` envionment (TODO)
	- Auto commit and deploy to `LIVE` envionment (TODO)


## Setup Instructions


1. **SSH PUBLIC KEY SETUP IN Pantheon**
* [Generate a new SSH key pair](https://docs.pantheon.io/ssh-keys) and add that to your account from that guide.

2. **Machine Tokens in Pantheon**
* [Generate a new Machine Token](https://docs.pantheon.io/machine-tokens#create-a-machine-token). This will be needed to control various workflows in Pantheon.

3. **Secret token SETUP IN GITHUB**

* Add the *SSH Private Key* & *Machine Token*  to your [Repository Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) or your [Organization Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-an-organization). Save the new secret "Name" as `PANTHEON_PRIVATE_KEY` & `PANTHEON_TERMINUS_MACHINE_TOKEN`

4. **YML SETUP**

* Create `.github/workflows/pantheon-deploy.yml` directory and file locally.
Copy and paste the configuration from the samples below replacing values accordingly.

5. Git push your site GitHub repo. The action will do the rest!

View your actions progress and logs by navigating to the "Actions" tab in your repo.


## Example GitHub Action workflow



Sample Github action that you can add in your repo

minimal options

```
name: Pantheon Build
on:
  push:
    branches:
      - main

jobs:
  github_deploy:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Pantheon Deploy
      uses: pantheoncarl/code-deploy-wp@main
      id: cache-vendor
      env:
        PANTHEONSITEUUID: 1234abcd-1234-abc-1111-1234abcd
        PANTHEON_TERMINUS_MACHINE_TOKEN: ${{ secrets.PANTHEON_TERMINUS_MACHINE_TOKEN }}
        PANTHEON_PRIVATE_KEY: ${{ secrets.PANTHEON_PRIVATE_KEY }}
```

all options options

```
name: Pantheon Build
on:
  push:
    branches:
      - main

jobs:
  github_deploy:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Pantheon Deploy
      uses: pantheoncarl/code-deploy-wp@main
      id: cache-vendor
      env:
        PANTHEONSITEUUID: 1234abcd-1234-abc-1111-1234abcd
		PANTHEONENV: multidev1
        PANTHEON_TERMINUS_MACHINE_TOKEN: ${{ secrets.PANTHEON_TERMINUS_MACHINE_TOKEN }}
        PANTHEON_PRIVATE_KEY: ${{ secrets.PANTHEON_PRIVATE_KEY }}
		PANTHEONENV_AUTODEPLOY: live
```


## Environment Variables & Secrets

### Required

| Name | Type | Usage |
|-|-|-|
| `PANTHEON_PRIVATE_KEY` | secrets | Private SSH Key. |
| `PANTHEON_TERMINUS_MACHINE_TOKEN` | secrets | Machine Token. |
| `PANTHEONSITEUUID` | string | Unique ID of the site that you will deploy to. |

### Deploy Options

| Name | Type | Usage |
|-|-|-|
| `PANTHEONENV` | string | Environment that your code will be deployed to, cannot beon test and live because it is write only. `dev`(default) and multidevs only. |
| `PANTHEONENV_AUTODEPLOY` | string | Can be set to auto deploy in `test` or `live`. if not set, it will default to the environment set in `PANTHEONENV` |
| `SRC_PATH` | string | Optional path to specify a directory within the repo to deploy from. Ex. `"wp-content/plugins/custom-plugin/"`. Defaults to root of repo filesystem as source. |
| `REMOTE_PATH` | string | Optional path to specify a directory destination to deploy to. Ex. `"wp-content/plugins/custom-plugin/"` . Defaults to WordPress root 
| `CACHE_CLEAR` | bool | Optionally clear page and CDN cache post deploy. This takes a few seconds. Default is FALSE. |
