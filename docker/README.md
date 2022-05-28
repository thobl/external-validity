# Usage #

Run all the commands from the root directory of the repository.

## Building and Saving the Image ##

```terminal
docker/build.sh
```

This creates the file `docker/ext_val.tar` (the docker image) and
`docker/ext_val.zip` (the image together with the scripts).

## Transferring the Image Different System ##

First copy the image and the scripts to where ever you want to run
it.  For example to a compute server.

```terminal
scp docker/ext_val.zip <server>:~/
```

Then, on the target computer, unpack and load the image so that docker
knows it.

```terminal
unzip ext_val.zip
cd ext_val/
./load.sh
```

## Preparing the Data ##

The following removes the existing data folder, creates a new one and
downloads the network data from zenodo.  It also creates all the
necessary folders.

```terminal
./setup_data.sh
```

## Running the Experiments ##

First you have to start the container.

```terminal
./run.sh
```

After the container has started, you can enter bash in the container.
If you want to use `screen` to be able to exit and later reenter the
container, this is the place to do it.

```terminal
./enter.sh
```

In the container, you can run the experiments.

```terminal
./run_and_build_plots.sh
exit
```

Don't forget to kill the container afterwards.

```terminal
./kill.sh
```

## Output Data ##

The output data is then located (in the host) under `ext_val/data/`.

# Notes #

## Removing Old Images ##

```console
docker images | grep none | awk '{ print $3; }' | xargs docker rmi --force
```
