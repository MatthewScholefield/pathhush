# pathhush

Tiny secret files that are harder to stumble into.

```sh
curl -fsSL https://raw.githubusercontent.com/MatthewScholefield/pathhush/main/install.sh | sh

pathhush create OPENAI_API_KEY --env .env
# Secret value: ********

cat .env
# OPENAI_API_KEY_FILE=/var/lib/pathhush/u1000/OPENAI_API_KEY--8c62...
```

The value lives in a non-listable directory. If you know the exact path, you can read it. If you don't, `ls`, globs, `find`, IDE scans, etc. don't casually discover it.

Useful with apps that support `*_FILE`, or Docker:

```yaml
services:
  app:
    volumes:
      - ${OPENAI_API_KEY_FILE}:/run/secrets/openai_api_key:ro
```

## stuff

```sh
pathhush create NAME           # hidden prompt
pathhush create NAME --env .env
pathhush path NAME
pathhush env NAME
pathhush list
pathhush remove NAME
pathhush doctor
pathhush update
```

Linux secrets live under `/var/lib/pathhush`; macOS uses `/usr/local/var/pathhush`.

## security-ish

Not a real secret manager. Not protection from malicious code running as you. If something knows the exact path, it can read the secret.

It's basically a small step up from putting plaintext secrets in `.env`: less likely to get inhaled by an AI agent, recursive search, editor indexer, or dumb opportunistic scanner.

That's it.
