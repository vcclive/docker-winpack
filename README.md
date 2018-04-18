# docker-winpack
Docker container based on suchja/wix:latest containing the following extra tools:
*innosetup
*reshacker
*xvfb

```
docker run --rm -it --entrypoint /bin/bash v install-win:/home/xclient/install-win vcc/winpack \
    xvfb-run -a wine reshack/ResHacker.exe -addoverwrite sample.exe, sample.exe, sample48.ico, Icon, sample,
```
