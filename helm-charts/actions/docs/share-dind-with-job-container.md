# Share dind with job container

You can weaken isolation and allow jobs to call docker commands.

## Limitations

- Docker bind mounts like `-v /path/on/self/container:/path/to/new/container` do not work, because they are going to mount the path from the dind container
- Docker port expose to local host `-e 80:8080` is not going to work

## Example Values

```yaml
enabled: true
statefulset:
  actRunner:
    # See full example here: https://gitea.com/gitea/act_runner/src/branch/main/internal/pkg/config/config.example.yaml
    config: |
      log:
        level: debug
      cache:
        enabled: false
      container:
        valid_volumes:
        - /var/run/docker.sock
        options: -v /var/run/docker.sock:/var/run/docker.sock

## Specify an existing token secret
##
existingSecret: "runner-token2"
existingSecretKey: "token"

## Specify the root URL of the Gitea instance
giteaRootURL: "http://192.168.1.2:3000"
```

Now you can run docker commands inside your jobs.