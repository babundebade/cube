# Basic OS Installation and Configuration

**Note: This section is a work in progress. The README and Terraform files will be updated accordingly.**

## Create a Talos Cluster with 1 Control Plane and 2 Workers

Follow these steps to create a Talos cluster with one control plane and two workers:

1. Install the [Talos ISO/image](https://www.talos.dev/v1.4/introduction/getting-started/#acquire-the-installation-image) using the [Raspberry Pi Imager](https://www.raspberrypi.com/software/) to SD cards or USB drives.
2. Insert the SD cards or USB drives into the nodes.
3. Power on the nodes and allow your DHCP server to assign IP addresses.
4. Install [talosctl](https://www.talos.dev/v1.4/introduction/quickstart/#talosctl) and other Talos prerequisites on your local machine (laptop or desktop) with LAN access to the network the nodes are in.
5. Update the settings in this repository to match your network, especially the files [variables.tf](./variables.tf) and [outputs.tf](./outputs.tf).
6. Run `terraform apply`.
7. The output will update your `talosctl` configuration file and your `kubectl` configuration file in the standard locations. To change that, modify the paths for the `local_sensitive_files` in the Terraform `outputs.tf` file.
8. Verify that everything is working correctly by running `kubectl get nodes` from your local machine console.
