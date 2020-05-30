# kcni-school-envs
A collection of docker environments for the KCNI Summer School

These dockers are posted to dockerhub so that they should be able to be "pulled" and run on any machine.

## How to run from the dockers

### Step 1. Install docker on your computer.

To install Docker follow the instructions at: https://www.docker.com/products/docker-desktop.

**If you have the "admin rights" (or the right to install software on the computer you are using)** This _should_ be relatively straight forward. Installing docker on some platforms (like Window's) usually means that you need to "allow virtualization" which is something that some workplace provided computers disable. If the installing docker is not possible at this time. See the next section (TBA) about accessing the environments via the Compute Canada Teach Cluster.

### Running the R and genomics environment

To start the R and genomics environment. Open up a terminal (in Windows this is PowerShell). And type:

** Note that this command has one "mount" or "bind" argument to allow you to attach one folder (or directory) from you computer to the container. This gives you one folder where you can read and write files from both you local computer programs, and from inside the container.

To download and install the software. When you run this - you should see a lot of things happening. Because Docker will first download the docker image or the software you need (~3G) then start up the environment. The "docker image" or the software will be saved to your computer, so this only needs to be run once..

```sh
## this installs the software
docker pull edickie/kcnischool-rstudio:latest
```

To run the system  - Remember to replace `<path/to/you/data>` with a location on your computer where you will be storing you KCNI school data)

```sh
## this runs the container
docker run --rm \
 -p 127.0.0.1:8787:8787 \
 -e DISABLE_AUTH=true \
 -v <path/to/your/data>:/home/rstudio/kcni-school-data \
 edickie/kcnischool-rstudio:latest
```

The first time you run this - you should see a lot of things happening. Because Docker will first download the docker image or the software you need (~3G) then start up the environment. The "docker image" or the software will be saved to your computer, so the next time you run this it will be faster.

Note: on window's powershell the `\` character doesn't work - so the link above needs to be all on one line..

```sh
docker run --rm -p 127.0.0.1:8787:8787 -e DISABLE_AUTH=true -v C:\Users\erin_dickie\data\kcni-school-data\:/home/rstudio/kcni-school-data edickie/kcnischool-rstudio:latest
```

When things calm down - you should see a message that "server" has start.
Then open your browser and navigate to: http://localhost:8787/ and you should see your rstudio terminal!

**Known Issue** when you come back to the school the next day. You may find that you get the error "port is already allocated". Because the software from the day before is still attached to the port. The easiest solution to this problem has been to restart your computer.

### Running the Jyputer Physiological Modeling Environment

We created a second environment that contains python and a jupyter notebook environment for Physiological Modeling.
This one is build (or installed) with a very similar command.

Building the env.
```sh
docker pull edickie/kcnischool-jupyter:latest
```

To run the system  - Remember to replace `<path/to/you/data>` with a location on your computer where you will be storing you KCNI school data)

```sh
docker run --rm \
  -p 8888:8888 \
  -v <path/to/your/data>:/home/neuro/kcni-school-data \
  edickie/kcnischool-jupyter:latest
```


For Erin (on Windows) the command looks like this.

```sh
docker run --rm -p 8888:8888 -v C:\Users\erin_dickie\data\kcni-school-data\:/home/neuro/kcni-school-data edickie/kcnischool-jupyter:latest
```

When this runs - you should see a web address starting with is printed to terminal. Copy and Paste this address into your browser and you should see the a jupyter notebook home!

---

## how to edit and rebuild these dockers from the github repo

### The R, rstudio and plink env for day 1.

Building it manually (should only need to do this when editing as an instructor)

```sh
cd rstudio-plink
docker build -t rstudio-plink:v04 -t rstudio-plink:latest .  
```

Running the container (from local build)

```sh
docker run --rm \
 -p 127.0.0.1:8787:8787 \
 -e DISABLE_AUTH=true \
 -v <path/to/your/data>:/home/rstudio/data \
 rstudio-plink:latest
```

Note: on window's powershell the `\` character doesn't work - so the link above needs to be all on one line..

```sh
docker run --rm -p 127.0.0.1:8787:8787 -e DISABLE_AUTH=true -v C:\Users\erin_dickie\data\kcni-school-data\:/home/rstudio/kcni-school-data rstudio-plink:latest
```

Then open your browser and navigate to: http://localhost:8787/ and you should see your rstudio terminal!

### The Python-Octave Env for Physiological Modelling

Building the env (this may only need to be done by the instructor)

```sh
docker build -t jupyter-neuron:v0.0 -t jupyter-neuron:latest .  
```

Running the env

```sh
docker run --rm -p 8888:8888 -v C:\Users\erin_dickie\data\kcni-school-data\:/home/neuro/kcni-school-data jupyter-neuron:latest
```
