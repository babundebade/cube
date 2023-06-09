# Basic OS installation

## Create a Talos cluster with 1 controlplane and 2 workers

1. install [talos iso/image](https://www.talos.dev/v1.4/introduction/getting-started/#acquire-the-installation-image) with [raspberry pi imager](https://www.raspberrypi.com/software/) to sd cards or usb drives
2. insert sd cards or usb drives into the nodes
3. power on the nodes, let your DHCP server assign ip addresses
4. install [talosctl](https://www.talos.dev/v1.4/introduction/quickstart/#talosctl) and other talos prerequisites on your local machine (your laptop or desktop) with LAN-access to network the nodes are in
5. change settings in this repo to match your network
6. run terraform apply
7. the output will update your talosctl config file and your kubectl config file in the standard locations. To change that, change the terraform output variables.

Work in progress. Readme and terraform files will be updated.