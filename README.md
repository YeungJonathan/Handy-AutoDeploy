# Handy-AutoDeploy
This repo includes several handy autodeploy scripts and systemd files using terraform and ansible.

This repo aims on deploying on the Vultr server. If you want to use GCP or AWS, please change the top part of the config.tf file.

When trying to autodeploy a server, please clone the repo and change the following things in the files:

## config.tf
- Change api key
- Change ssh key 
- Change main instance
- Change remote execute private key
- Change remote execute github repo that you are deploying
- Change last remote execute for handling ansible playbook and steps after that

## host file
- Change the service name

## bob-service.yaml
- Change this file according to the ansible playbook that you want to run

## bobSystemd.yaml
- Change the name of the systemd file that you want to use

## bob.service
- Change the name, directory and the binary file that you want to auto-restart when the service crashes
