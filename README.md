# g0v.network domains [![domain-sync][badge]][workflows]

For automating management of some g0v-related domains via config files.

The following damains can be managed here:
- `g0v.network`
- `g0v.ca`
- `c4nada.ca`
- `t0ronto.ca`

Changing or adding DNS records in `main` branch of this repository will update
the actual domain records.

Inspired by [`g0v/domain`][g0v/domain]

   [g0v/domain]: https://github.com/g0v/domain

## Table of Contents

- [Technologies Used][tech]
- [Usage][usage]
- [Development][dev]
- [Contributing][contrib]
- [Licensing][license]

   [tech]: #hammer_and_wrench-technologies-used
   [usage]: #balloon-usage
   [dev]: #woman_technologist-development
   [contrib]: #muscle-contributing
   [license]: #copyright-license

## :hammer_and_wrench: Technologies Used

- [**YAML.**][yaml] A human-friendly configuration file format.
- [**octoDNS.**][octodns] Command-line tool to update domain records from files -- infra-as-code!
- [**GitHub Actions.**][gh-actions] Continuous integration platform to run automation in the cloud.
  - [**octoDNS Sync action.**][octosync] Helps validate and run octoDNS.

   [yaml]: https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html
   [octodns]: https://github.com/octodns/octodns
   [gh-actions]: https://github.com/features/actions
   [octosync]: https://github.com/solvaholic/octodns-sync

## :balloon: Usage

The intended way to use this repository is via pull request directly on GitHub.

For support in managing common DNS changes and adding new domains, see
[`docs/HOWTO.md`](/docs/HOWTO.md).

To learn to submit changes, see [Contributing][contrib]

<sub>(You should only need to clone this code locally if working on the
automation itself. See <a href="#woman_technologist-development">Development section</a>.)</sub>

## :woman_technologist: Development

To contribute changes to our automation, you'll likely want to be able to run it locally. Here's what you'll need:

<details>
  <summary>Prerequisites</summary>

  - [Install][py3] Python 3
  - [Install][pipenv] `pipenv`.
  - [Register][cf-user] a Cloudflare user account
    - any non-special account will do
  - [Add][cf-website] each Cloudflare domain/zone/website (those mentioned above)
    - you can "fake it" by initiating the import process, without activating (ie. no need to have access to the actual domain)
  - Generate a properly scoped Cloudflare API token
    - [Documentation][cf-token-docs] for creating tokens [in your profile][cf-token]
    - Permissions: `Zone | DNS | Edit`
    - Zone Resources: `Include | Specific zone | example.com` for each zone/domain
      - Alternatively: `Include | All zones from an account`

</details>

   [py3]: https://realpython.com/installing-python/
   [pipenv]: https://pipenv.pypa.io/en/latest/#install-pipenv-today
   [cf-user]: https://dash.cloudflare.com/sign-up
   [cf-website]: https://support.cloudflare.com/hc/en-us/articles/201720164-Creating-a-Cloudflare-account-and-adding-a-website
   [cf-token-docs]: https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys#12345680
   [cf-token]: https://dash.cloudflare.com/profile/api-tokens

```
git clone https://github.com/g0v-network/domains
cd domains

pipenv install

# Validate your config locally
pipenv run octodns-validate --config-file config.yaml

# Copy and modify as needed with API token
cp sample.env .env

# Do a dry run against Cloudflare (no changes will be made)
pipenv run octodns-sync --config-file config.yaml

# Do a REAL run (!!!)
#
# WARNING: this is destructive, and will delete any records on a domain that
# are not present in your configuration files.
pipenv run octodns-sync --config-file config.yaml --doit
```

## :muscle: Contributing

Please open an issue or pull request in order to create/update/delete any
subdomains.

See [`docs/HOWTO.md`](/docs/HOWTO.md) for detailed instructions.

## :copyright: License

[CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

<!-- Links -->

   <!-- Pre-filled file contents url encoded via tool. See: https://meyerweb.com/eric/tools/dencoder/ -->
   [new-subdomain]: https://github.com/g0v-network/domains/new/main?filename=g0v.network./my.example.g0v.network.yaml&value=my.example%3A%0A%20%20-%20type%3A%20A%0A%20%20%20%20values%3A%0A%20%20%20%20%20%20-%20123.45.67.89%0A%20%20%20%20metdata%3A%0A%20%20%20%20%20%20repository%3A%20https%3A%2F%2Fgithub.com%2Fg0v-network%2Ffoo%0A%20%20%20%20%20%20maintainer%3A%0A%20%20%20%20%20%20%20%20-%20some-github-user
   [badge]: https://github.com/g0v-network/domains/workflows/domain-sync/badge.svg?branch=main
   [workflows]: https://github.com/g0v-network/domains/actions?query=workflow:domain-sync
