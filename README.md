# Packer Imaging, Terraform Deployment
A small snippet of code how you build custom images from Packer, then Terraform deploy the latest version of that image. This is a good method to host immutable images, where there's no need for you to remote into the VM, as the image already has the necessary packages, files etc. 

## Ubuntu 20.04 CIS Image
In this build, I decided to use CIS build images. These images come fully secured by them. To be able to use them, you will need to accept the terms of the image (otherwise Packer will fail). The below command will accept the terms of the image used in this example.

```bash
az vm image terms accept --urn center-for-internet-security-inc:cis-ubuntu-linux-2004-l1:cis-ubuntu2004-l1:1.0.3 --subscription {your-sub-id}
```

## Building the Shared Image Gallery
Build out shared image gallery using the plan.sh file within /terraform/sig. This is where your Packer image versions will be stored.

## Building the Packer image
To build out the Packer image, make sure to have Ansible installed. In this case, this simply installs the nginx package and restarts the service. To build out a versioned image you would run the below command from the Packer folder. The build script just handles the Packer build command, and you're passing the version number through too. Azure works with semantic versioning. 

```bash
./build.sh "0.0.1"
```
---
**NOTE**

The SIG would consider "0.0.1" the "latest" image version, then your terraform would up pick up on this latest considered image. 

The versioning goes from "0.0.1" to "0.0.9". Meaning "0.0.10" would not be considered the latest. After "0.0.9", the next version to be considered "latest", would be "0.1.1".  

---

## Building the VM

Now with an image version stored in your shared image gallery. You can build the VM using that image. Again, just run the plan.sh file from the /terraform/vm folder this time. This will build the necessary resources to get you setup to build the image and connect to it. 

And the next time you build out a new version of the image, you just do the same. The terraform will see there's a newer version of the image and will recreate the VM using that. 