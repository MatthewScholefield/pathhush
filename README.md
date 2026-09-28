# pathhush

Tiny secret files that are harder to stumble into.

## install

```sh
curl -fsSL https://raw.githubusercontent.com/MatthewScholefield/pathhush/main/install.sh | sh
```

## use

```sh
$ pathhush create OPENAI_API_KEY
Secret value: ********
Secret path: /var/lib/pathhush/u1000/OPENAI_API_KEY--8c62...
/var/lib/pathhush/u1000/OPENAI_API_KEY--8c62...
```

The last line is stdout. So:

```sh
secret_path=$(pathhush create OPENAI_API_KEY 'sk-whatever')
```

Or, if you happen to use env files:

```sh
pathhush create OPENAI_API_KEY --env-file .env
```

The value lives in a non-listable directory. Know the exact path? You can read it. Don't? `ls`, globs, `find`, IDE scans, etc. don't casually discover it.

## stuff

```sh
pathhush create NAME                 # hidden prompt
pathhush create NAME 'secret value'  # scripts
pathhush create NAME --stdin
pathhush create NAME --env-file .env
pathhush path NAME
pathhush env NAME
pathhush list
pathhush remove NAME
pathhush doctor
pathhush update
```

Linux: `/var/lib/pathhush`. macOS: `/usr/local/var/pathhush`.

## security-ish

Not a real secret manager. Malicious code running as you can read a known path.

Basically a small step up from plaintext in `.env`: harder for an AI agent, recursive search, editor indexer, or dumb scanner to accidentally inhale.

That's it.
