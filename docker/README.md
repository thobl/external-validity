# Basic Steps #

## Local Setup & Testing ##

### Starting Docker ###

Alternatively use ``enable`` for automatic start on startup.

```console
systemctl start docker
```

### Building the Image ###

```console
docker image build -t ext_val .
```

### Running It ###

```console
docker run --name ext_val --rm -v $PWD/data/input_data:/ext_val/input_data -v $PWD/data/output_data:/ext_val/output_data --user "$(id -u):$(id -g)" ext_val
```

### Entering the Container ###

```console
docker exec -it ext_val bash
```

### Stopping the Container ###

```console
docker kill ext_val
```

### Removing Old Images ###

```console
docker images | grep none | awk '{ print $3; }' | xargs docker rmi --force
```

## Distributing the Image ##

### Export the Image ###

```console
docker save -o ext_val.tar ext_val
```

### Loading the Image File ###

```console
docker load -i ext_val.tar
```
