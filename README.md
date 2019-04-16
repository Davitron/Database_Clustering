# Database_Clustering
A project that demonstrates how to setup a multiple  PostgreSQL databases and loadbalancing them. The project leverages the power of Haproxy as a load balancer. Packer is used to create machine images for Haproxy, NAT, master and 2 slave databases. Google Cloud Provider(GCP) is where the infrastructure runs on.

#### HOW TO SET UP

- Clone this repo
- Cd into the project
- Run `export PROJECT_ID="YOUR_GCP_PROJECT_ID"` in the terminal
- Create a folder called `secrets` in the root directory of this project
- [Get your service account key from GCP](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) and place the json file in the folder( Ensure you have already created an [account]() and [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) before you do so)

##### create images
- cd into `/images/templates`
- validate the packer templates with the following commands
   ```
    packer validate haproxy.json
    packer validate master.json
    packer validate slave.json
   ```
- build the images with
  ```
    packer build haproxy.json
    packer build master.json
    packer build slave.json
  ```

##### Create infrastructure
 - Update the `variable.tf` file with your variables. The 3 images created earlier are also required in the file.
  The variables consist of the following:
    - images of the Haproxy Load-Balancer, Master and Slave database created with Packer
    - Image type for the NAT instance ( You should use `ubuntu-1604-xenial-v20181004` prefarably)
    - IPV4 CIDR for the public and private subnet
    - IP addresses for each instance ( Ensure that they are compatible CIDR specified for the subnet that houses them)
    - Database Password for the master database
    - The machine type (`f1-micro` seems efficient enough for the project)
    - The region
 - Run the following commands
    ```
      teraform init
      terraform plan
      terraform apply
    ```
