# Raspberry Pi Kubernetes Cluster with Talos

**Note: This project is currently a work in progress and will be updated accordingly.**

## Project Overview

The main objective of this project is to create a self-hosted Kubernetes cluster using Raspberry Pi devices and Talos, an operating system specifically designed for Kubernetes. The cluster setup makes use of Terraform for provisioning the required infrastructure components and services.

### Repository Structure
|Directory|Description|
|:---|:---|
|[.talos](.talos)|Contains the Talos configuration files|
|[infrastructure](infrastructure)|Contains all files to setup infrastructure services such as metallb, ingress-nginx, storage, ...|
|[apps](apps)|Contains all files to setup applications such as home-assistant, nextcloud, ...|
|[`rdmassets`](rdmassets)|Contains images and other assets used in the README|

### My Homelab setup:

||Device|Role|Attachment|
|:---|:---|:---|:---|
|:top:**TOP**|Mikrotik router RB4011iGS+5HacQ2HnD-IN     |Router         ||
|:large_blue_circle:**BLUE**|Raspberry Pi 4 Model B       |Control Plane  |-[32 GB USB 3.1 Flash Drive](https://www.amazon.de/dp/B09FFK1QLR?psc=1&ref=ppx_yo2ov_dt_b_product_details) for Talos OS<br />-[SONOFF ZigBee 3.0](https://sonoff.tech/product/gateway-and-sensors/sonoff-zigbee-3-0-usb-dongle-plus-p/) to connect smart home devices|
|:red_circle:**RED**|Raspberry Pi 4 Model B          |Worker         |-[32 GB USB 3.1 Flash Drive](https://www.amazon.de/dp/B09FFK1QLR?psc=1&ref=ppx_yo2ov_dt_b_product_details) for Talos OS<br />-[1TB 3D NAND SATA 2,5" SSD](https://www.amazon.de/gp/product/B078211KBB/ref=ppx_yo_dt_b_asin_title_o09_s00?ie=UTF8&psc=1) for cluster-storage|
|:yellow_circle:**YELLOW**|Raspberry Pi 4 Model B |Worker         |-[32 GB USB 3.1 Flash Drive](https://www.amazon.de/dp/B09FFK1QLR?psc=1&ref=ppx_yo2ov_dt_b_product_details) for Talos OS<br />-[1TB 3D NAND SATA 2,5" SSD](https://www.amazon.de/gp/product/B078211KBB/ref=ppx_yo_dt_b_asin_title_o09_s00?ie=UTF8&psc=1) for cluster-storage|
|:green_circle:**GREEN**|Raspberry Pi 3 Model B+   |Not in use     ||

![Server-Cube](rdmassets/Pi-Rack.jpg "Raspberry Pi´s in a rack with a router")

## Contributing

Contributions to this project are welcome! If you find any issues, have suggestions for improvements, or would like to add new features, please submit a pull request. :) 

## License

This project is licensed under the [MIT License](LICENSE), which allows for open collaboration and encourages sharing and improvement of the codebase.

## Donate

If you find this project helpful and would like to support its development, you can donate via PayPal:

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/lariodudwig)

Your contributions are greatly appreciated!