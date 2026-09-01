# Verdaccio — npm.pipedocs.app

Registry NPM privado com config versionado no Git, seguindo a [documentação oficial do Verdaccio](https://verdaccio.org/docs/docker).

## Como funciona

O `config/config.yaml` é copiado para dentro da imagem no build (`Dockerfile`).  
Não usamos bind mount de config — isso **não funciona** em stacks Swarm do Portainer.

Volumes nomeados (recomendado pela doc oficial):

| Volume              | Uso                                      |
|---------------------|------------------------------------------|
| `verdaccio_storage` | Pacotes publicados + `htpasswd`          |
| `verdaccio_plugins` | Plugins opcionais                        |

## Acesso público

Todos os pacotes com leitura e publicação abertas (`access/publish/unpublish: $all`).

## Deploy no Portainer

1. **Stacks → Add stack → Repository**
2. URL: `https://github.com/eduals/verdaccio`
3. Compose path: `docker-compose.yml`
4. Ative **Build the image** (obrigatório — a imagem inclui o config)
5. Deploy / Pull and redeploy

A cada alteração em `config/config.yaml`: commit, push e **Pull and redeploy** (rebuild da imagem).

## Migrar usuários do volume antigo

Se tinha `htpasswd` no volume `verdaccio_conf`:

```bash
docker run --rm -v verdaccio_conf:/from -v verdaccio_storage:/to alpine \
  sh -c "cp /from/htpasswd /to/htpasswd 2>/dev/null || true"
```

Pacotes no `verdaccio_storage` são preservados automaticamente.

## Usar o registry

```bash
npm login --registry=https://npm.pipedocs.app
npm publish --registry=https://npm.pipedocs.app
```

`.npmrc` no projeto:

```
registry=https://npm.pipedocs.app/
```

## Referências

- [Verdaccio Docker docs](https://verdaccio.org/docs/docker)
- [docker.yaml oficial](https://github.com/verdaccio/verdaccio/blob/master/packages/config/src/conf/docker.yaml)
- [Variáveis de ambiente](https://verdaccio.org/docs/env)
