# Database_Clustering
A project that demonstrates how to setup a multiple  PostgreSQL databases and loadbalancing them. The project leverages the power of Haproxy as a load balancer. Packer is used to create machine images for Haproxy, NAT, master and 2 slave databases. Google Cloud Provider(GCP) is where the infrastructure runs on.

#### HOW TO SET UP

- Clone this repo
- cd into the project
- run `export PROJECT_ID="YOUR_GCP_PROJECT_ID" in the terminal
- create a folder called `secrets` in the root directory of this project
- get your service account key from GCP and place the json file in the folder 

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
 - update the `variable.tf` file with your variables. The 3 images created earlier are also required in the file
 - run the following commands
    ```
      teraform init
      terraform plan
      terraform apply
    ```