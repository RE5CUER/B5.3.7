terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.133.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "./authorized_key.json"  # Указание пути к вашему сервисному ключу
  cloud_id  = "b1grqh71vdqnc524jnl2"  # Ваш Cloud ID
  folder_id = "b1g7k2ksqp16q3ae0mcb"  # Ваш Folder ID
  zone      = "ru-central1-a"   # Укажите зону
}

data "yandex_compute_image" "my_image" {
  family = "lemp"
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/grid/.ssh/id_rsa.pub")}"
  }
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
