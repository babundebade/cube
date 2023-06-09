<style>
red { color: red }
yellow { color: orange }
green { color: green }
blue { color: blue }
</style>
# Raspberry Pi Kubernetes Cluster with Talos

Work in progress...

## Project Overview

The main objective of this project is to create a Kubernetes cluster on Raspberry Pi devices using Talos, an OS designed specifically for Kubernetes. The cluster setup utilizes Terraform for provisioning the necessary infrastructure components but also services.

### My Homelab setup:
- TOP Mikrotik router RB4011iGS+5HacQ2HnD-IN
- <green>**GREEN**</green> Raspberry Pi 3 Model B+ (not in use yet)
- <yellow>**YELLOW**</yellow> Raspberry Pi 4 Model B (Worker 192.168.1.12)
- <red>**RED**</red> Raspberry Pi 4 Model B (Worker 192.168.1.11)
- <blue>**BLUE**</blue> Raspberry Pi 4 Model B (Control Plane 192.168.1.10)
- [3x SanDisk Ultra Fit 32 GB USB 3.1 Flash Drive](https://www.amazon.de/dp/B09FFK1QLR?psc=1&ref=ppx_yo2ov_dt_b_product_details) on <blue>**BLUE**</blue>, <yellow>**YELLOW**</yellow> and <red>**RED**</red>
- 2x 1TB SSD for cluster-storage on <yellow>YELLOW</yellow> and <red>RED</red>
- [1x SONOFF ZigBee 3.0 for smart home devices](https://sonoff.tech/product/gateway-and-sensors/sonoff-zigbee-3-0-usb-dongle-plus-p/) on <blue>BLUE</blue>
![Server-Cube](rdmassets/Pi-Rack.jpg "Raspberry Pi´s in a rack with a router")

## Contributing

Contributions to this project are welcome! If you find any issues, have suggestions for improvements, or would like to add new features, please submit a pull request. :) 

## License

This project is licensed under the [MIT License](LICENSE), which allows for open collaboration and encourages sharing and improvement of the codebase.

## Donate

If you find this project helpful and would like to support its development, you can donate via PayPal:

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/lariodudwig)

Your contributions are greatly appreciated!