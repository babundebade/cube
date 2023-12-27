# FILEPATH: main.py

# This code snippet demonstrates the importance of installing Custom Resource Definitions (CRDs) before creating Custom Resources (CRs) in Kubernetes. Additionally, it explains why an extra apply run is required in Terraform at the moment.

# CRDs are Kubernetes API extensions that define new resource types. They allow users to define and manage custom resources in a Kubernetes cluster. Before creating CRs, it is necessary to install the corresponding CRDs to ensure that the Kubernetes API server recognizes and understands the custom resource schema.

# In this code, the order of operations is crucial. If CRs are created before the corresponding CRDs are installed, the Kubernetes API server will not recognize the custom resource schema, resulting in errors or unexpected behavior.

# Furthermore, the current implementation of Terraform requires an extra apply run to ensure that the CRDs are installed before creating the CRs. This is because Terraform's execution plan does not include the installation of CRDs by default. By running apply twice, the first run installs the CRDs, and the second run creates the CRs using the installed CRDs.

# It is important to note that this behavior may change in future versions of Terraform, so it is recommended to refer to the official Terraform documentation for the most up-to-date information.

# To ensure a smooth deployment and avoid any issues, please follow the following steps:
# 1. Install the necessary CRDs using the provided installation instructions or manifests.
# 2. Run Terraform apply twice to first install the CRDs and then create the CRs.

# For more information and detailed instructions, please refer to the project's README file.

def main():
    # Your code here
    pass

if __name__ == "__main__":
    main()
