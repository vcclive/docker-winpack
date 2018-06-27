# docker-winpack
Docker container based on suchja/* and Ubuntu Bionic (18.04) containing the following extra tools:
* wine32, wine64
* reshacker (tested with 4.7.34)
* wix toolset 3.11
* xvfb
* mono 4.7.1
* .NET Framework 4.0

The default wine environment is 32bit.

Build variables (e.g. docker build --build-arg myuid=1111 ...):
* myuid
* mygid


```
docker run --rm -it --entrypoint /bin/bash -v install-win:/home/jenkins/install-win vcc/winpack \
    xvfb-run -f /home/jenkins/.Xauthority -a wine reshack/ResourceHacker.exe -open sample.exe -save sample_new.exe -action delete -mask
,,, -log CONSOLE
```
