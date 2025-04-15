# Personal Portfolio Mikel Dalmau

Personal portfolio website built with elm, elm

This website design is based on [www.stevenmengin.com](https://www.stevenmengin.com/) website, the website is intended to evolve and gradually distantiate on this aspect, as all implementation and tecnical solutions have been done by myself, skipping as much as possible from the desing process has been really helpful.

- [Personal Portfolio Mikel Dalmau](#personal-portfolio-mikel-dalmau)
  - [Install](#install)
  - [Build the source code](#build-the-source-code)
  - [Build the elm code](#build-the-elm-code)
  - [Generate images](#generate-images)
  - [Docker](#docker)
    - [Build Docker image with docker compose](#build-docker-image-with-docker-compose)
    - [Download and run docker image from docker hub](#download-and-run-docker-image-from-docker-hub)
  - [Resources](#resources)

## Install

Run npm for required packages

```npm install```

Run for gulp client

```npm install --global gulp-cli```

Download the elm installer

https://guide.elm-lang.org/install/elm.html

For the image generation feature, this may require removing the dependecy from package.json and running ``npm install`` before the next command.
    
```npm install --save-dev gulp-sharp-responsive```

## Build the source code

Source code is built and added to build folder using gulp command.

```gulp``` 

This command will run a live server and compile elm on changes, also some command for image generation is available, 
allowing to create different versions of images for sizes and formats.

## Build the elm code

The gulp task will run the following command to build the Elm code.

```elm make src/Main.elm --output build/main.js```

## Generate images

Generate the images with the command

```gulp tabImageOptimizerTask --tab 1```

 
Define the desired configuration at galleryImages.json as shown:

<img src="readme-imgs/image-config.png"  width="20%" height="30%">


## Docker

### Build Docker image with docker compose

Build and build image and run container
```docker compose up --build```

Run container on detached mode
```docker compose up -d```

### Download and run docker image from docker hub

To download image using dockerhub

```docker pull mikeldalmauc/portfoliov2```

or directly download and run it with 

```docker run -d -p 8080:8080 -e --name=portfolioV2 mikeldalmauc/portfoliov2:1.0```

## Resources

https://package.elm-lang.org/

https://package.elm-lang.org/packages/mdgriffith/elm-ui/
