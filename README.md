# pathhush

*A simple tool to dump secrets into files*

Instead of putting secrets in .env files and making it easy for agents to accidentally read them, just put them in separate files.

This tool does simply that—give it a secret name and value and it writes it to a randomly generated file path on your system in a provisioned folder that has restricted listing permissions so only root can list the contents.

Additional benefit: If all your actual secrets are in separate files then you can instruct agents to directly modify .env files without worrying about secrets leaking into LLM provider logs.

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

## install

```sh
curl -fsSL https://raw.githubusercontent.com/MatthewScholefield/pathhush/main/install.sh | sh
```

## stuff

```sh
pathhush create NAME                 # hidden prompt
pathhush create NAME 'secret value'  # for use in scripts
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

## security

This is not a real secret manager. Items are encoded in plain text and directly readable by the current user. So this is basically meant as a convenience to prevent accidentally exposing secrets not as a truly secure secret storage system.
