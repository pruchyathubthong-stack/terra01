provider "vsphere" {
  user                 = "administrator@vsphere.local"
  password             = "P@ssw0rd"
  vsphere_server       = "10.200.124.40"
  allow_unverified_ssl = true
}

# Datacenter
data "vsphere_datacenter" "dc" {
  name = "MCC-IBM3650-Datacenter"
}

# Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = "MCC-IBM3650-Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Datastore
data "vsphere_datastore" "ds" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Template VM
data "vsphere_virtual_machine" "template" {
  name          = "mcc_pudrhel9-template-build"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Virtual Machine (จาก template)
resource "vsphere_virtual_machine" "vm" {
  name             = "testterraform01000"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 2
  memory   = 2048

  # Clone จาก template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "testterraform0100"
        domain    = "local"
      }

      network_interface {
        ipv4_address = "10.200.124.247"  # ปรับ IP ตามต้องการ
        ipv4_netmask = 23
      }

      ipv4_gateway = "10.200.124.1"
    }
  }

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 20
    thin_provisioned = true
  }
}

