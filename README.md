# audioForge
An attempt to have available audio tools to rip audio cds, make audio conversions, manage tags...  with a docker image

## Build

```
DOCKER_BUILDKIT=1 docker build --progress=plain  -t audioforge:latest -f Dockerfile .

```

## Run

Rip audio CD with tags


```

# docker run -it --rm --device=/dev/yourcddevice:/dev/cdrom -v /local/rip/directory:/tmp/RIP audioforge:latest r
```

## Working

- Rip to WAV with basic tags using CDDB and with possibility to add your own tags

## TODO

- Encode to FLAC, ALAC with tags (In progress)
