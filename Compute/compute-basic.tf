#This section is used to specify basic information that can be used al around are code like the provider, project, etc.
provider "google" {
  version = "3.5.0"

  project = "alan-terraform-course"
  region  = "us-central1"
  zone    = "us-central1-c"
}

#input variable for how much VMs & static IPs will be created
variable "amount"{
  type = number
}

#Here we create a vpc called terraform-network
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_address" "static"{
  count = var.amount
  name = "terraform-static-ip-${count.index+1}"
}

#here we create an instance with its basic config like nw,image,name,external ip (ephemeral),etc.
resource "google_compute_instance" "my_vm"{
  count = var.amount
  name = "terraform-${count.index+1}"
  machine_type ="f1-micro"
  allow_stopping_for_update = "true"
  tags = ["foo","bar"]

  boot_disk{
    initialize_params{
      image = "debian-cloud/debian-9"
    }
  }

  network_interface{
    network = "terraform-network"

    access_config{
      nat_ip = google_compute_address.static[count.index].address
    }
  }

 service_account{
  scopes = ["cloud-source-repos"]
 }

  

#this is were we specify were are terraform state will be stored
}
terraform{
  backend "gcs"{
    bucket = "my-terraform-testing"
    prefix = "terraform"
  }
}
