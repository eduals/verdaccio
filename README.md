# Verdaccio — npm.pipedocs.app

Repositório para gerenciar a configuração do registry NPM privado (Verdaccio) usado em produção.

## O que mudou em relação ao setup anterior

Antes, o `config.yaml` ficava preso no volume Docker `verdaccio_conf`, impossível de editar pelo Portainer.

O `config/config.yaml` é baixado do GitHub na inicialização do container (sem bind mount — compatível com Portainer/Swarm):

```yaml
CONFIG_URL=https://raw.githubusercontent.com/eduals/verdaccio/main/config/config.yaml
```

Edite `config/config.yaml`, faça push e **redeploy/restart** da stack para aplicar.

## Acesso público aos pacotes

No `config/config.yaml`, a seção `packages` está configurada com:

| Permissão   | Valor            | Efeito                                      |
|-------------|------------------|---------------------------------------------|
| `access`    | `$all`           | Qualquer pessoa pode **baixar** pacotes     |
| `publish`   | `$authenticated` | Só usuários logados podem **publicar**      |
| `unpublish` | `$authenticated` | Só usuários logados podem **despublicar**   |

Para permitir publicação sem login (não recomendado em produção), troque `publish` e `unpublish` para `$all`:

```yaml
packages:
  '**':
    access: $all
    publish: $all
    unpublish: $all
    proxy: npmjs
```

## Deploy no Portainer

### Opção A — Stack via Git (recomendado)

1. Faça push deste repo para o GitHub.
2. No Portainer: **Stacks → Add stack → Repository**.
3. Cole a URL do repositório e aponte para `docker-compose.yml`.
4. Ative **Automatic updates** se quiser redeploy automático ao push.

### Opção B — Clone no servidor

```bash
git clone https://github.com/eduals/verdaccio.git
cd verdaccio
docker compose up -d
```

## Migrar do volume antigo

Se você já tinha pacotes e usuários no volume `verdaccio_conf`:

```bash
# Copiar htpasswd com usuários existentes
docker run --rm -v verdaccio_conf:/from alpine sh -c "cat /from/htpasswd" > config/htpasswd

# Se quiser preservar o config antigo para comparar
docker run --rm -v verdaccio_conf:/from alpine sh -c "cat /from/config.yaml" > config/config.yaml.bak
```

O volume `verdaccio_storage` continua igual — seus pacotes publicados não são perdidos.

## Criar usuário para publicar

```bash
docker exec -it verdaccio npm adduser --registry https://npm.pipedocs.app
```

Ou acesse https://npm.pipedocs.app e registre-se pela UI.

## Usar o registry

```bash
npm login --registry=https://npm.pipedocs.app
npm publish --registry=https://npm.pipedocs.app
```

Para um projeto específico, crie um `.npmrc`:

```
registry=https://npm.pipedocs.app/
//npm.pipedocs.app/:_authToken=${NPM_TOKEN}
```

## Aplicar mudanças no config

1. Edite `config/config.yaml` neste repositório.
2. Commit e push.
3. No Portainer, redeploy a stack ou reinicie o container:

```bash
docker compose restart verdaccio
```
