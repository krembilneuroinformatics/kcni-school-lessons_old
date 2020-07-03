# working with tutorial code on

scinetguest230 RPNzcrFVn7

For those who can't get Docker installed on their personal machines. We have the option to use singularity on Compute Ontario resources instead! (Thank you Compute Ontario!)

To use this, please ask your TA, or email KCNI.school@camh.ca for at temporary username and password for the SciNet system.

Getting to these services looks complicated but all you should need one your local computer is a linux terminal or a linux terminal simulator. (I, for windows, use gitbash https://gitforwindows.org/, you could also use putty or mobaxterm.

# Part 1: For the rstudio-plink environment (Days 1, 2 and 5)

Note: this is not as fancy as what SciNet wants (with a debugjob). The without running a debugjob way...Ramses would not be impressed - but the queue isn't working..

To get access to the rstudio-plink environment - you need access to three things

- **SciNet Username**: contact the TA's or KCNI.school@camh.ca to get one!
    - referred to in code sections below as `<username>`
- **SciNet Passworkd**: should get this with your username
    - referred to in code sections below as `<password>`
- **Your very own port number**: pick a number between 2000-9999 and hold onto it!
    - referred to in code sections below as `<your-port>`

## Step 1.1 Connect to SciNet teach node

```sh
ssh -L8787:localhost:<your-port> <username>@teach.scinet.utoronto.ca
```

## Step 1.2 start a debugjob

A debugjob will insure that we are not sitting on one of the most busy computers. It will timeout after 4 hours - but that is enough time for our tutorials!

```sh
debugjob
ssh -f -N -T -R <your-port>:localhost:<your-port> <your-username>@teach.scinet.utoronto.ca
```

## Step 1.3 start rstudio in singularity on SciNet

This part is kinda involved - but just copy and paste..
Note that you need to substitute `<your-password>` and `<your-port>` in the appropriate places

```sh
export RSTUDIO_PASSWORD=<your-password>
singularity exec \
  --home $SCRATCH/kcni-school-data:/home/rstudio/kcni-school-data \
  --bind /scinet/course/ss2019/3/8_bayesianmri/rstudio_auth.sh:/usr/lib/rstudio-server/bin/rstudio_auth.sh \
  /scinet/course/ss2020/5_neuroimaging/containers/edickie_kcnischool-rstudio_latest-2020-06-26-a07309756986.sif \
  rserver \
  --auth-none 0 \
  --auth-pam-helper-path rstudio_auth.sh \
  --www-port <your-port>
```

Attaching the tunnel all the way out

## Step 1.4 open the browser on you local machine.

Open your browser (i.e. google-chrome, safari or firefox) and point your browser at localhost:8787 and you should see rstudio!!

It will prompt for a username and password. This will be `<your-username>` and `<your-password>`


# Part 2. Cloning the KCNI lession Material

Inside the rstudio instance - you can clone the kcni school code into you home!

```sh
cd kcni-school-data
git clone --recurse-submodules https://github.com/krembilneuroinformatics/kcni-school-lessons.git
```

# Part 3: Getting the jupyter envs (for day 3)

```sh
singularity run \
  --home $SCRATCH/kcni_school_data:/home/neuro/ \
  /scinet/course/ss2020/5_neuroimaging/containers/edickie_kcnischool-jupyter_latest-2020-06-30-80999c06ecbb.sif
```

```sh
ssh -L8888:localhost:8888 <username>@teach.scinet.utoronto.ca
```

Then we can copy and paste the address that appears after own singularity run in our browser

For example I saw this message with the address to copy and paste..
```
Or copy and paste one of these URLs:
        http://teach01.scinet.local:8888/?token=0c4f675b02b88455630c12bd2cf9e41a64c4afa2e0861b6a
     or http://127.0.0.1:8888/?token=0c4f675b02b88455630c12bd2cf9e41a64c4afa2e0861b6a
```


The without running a debugjob way...Ramses would not be impressed


## appendix: how this was built by the instructors

We converted the docker containers to singularity containers so that they could be run on the SciNet HCP.

```sh
docker run -v /var/run/docker.sock:/var/run/docker.sock -v C:\Users\erin_dickie\data:/output --privileged -t --rm quay.io/singularity/docker2singularity edickie/kcnischool-rstudio:latest
```

```sh
docker run -v /var/run/docker.sock:/var/run/docker.sock -v C:\Users\erin_dickie\data:/output --privileged -t --rm quay.io/singularity/docker2singularity edickie/kcnischool-jupyter:latest
```
