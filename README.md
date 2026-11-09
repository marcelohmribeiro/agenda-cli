# AgendaCli

## Instalação

```bash
mix deps.get
```

## Uso

```bash
mix run -e "AgendaCli.main()"
```

Os contatos são salvos em `contacts.json`.

| Comando | Exemplo |
|---|---|
| `add` | `add --name Ana Lima --company Acme --phone 85912345678 --email ana@acme.com` |
| `edit <id>` | `edit 123 --phone 85912341234` |
| `del <id>` | `del 123` |
| `show <id>` | `show 123` |
| `list` | `list` |
| `search` | `search --name ana` (ou `--phone`, `--email`, `--company`) |
| `help` | `help` |
| `exit` | `exit` |

## Módulos

- `AgendaCli`: `main/1`, loop interativo (recursão de cauda)
- `AgendaCli.Contacts`: funções puras sobre a lista de contatos
- `AgendaCli.Store`: leitura e escrita do `contacts.json`
