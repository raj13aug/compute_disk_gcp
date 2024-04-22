variable "name" {
  description = "Name of a Google Cloud Project"
  default     = "cloudroot7-demo"
}

variable "id" {
  description = "ID of a Google Cloud Project. Can be omitted and will be generated automatically"
  default     = "mytesting-400910"
}

variable "project_id" {
  type        = string
  description = "project id"
  default     = "mytesting-400910"
}

variable "region" {
  type        = string
  description = "Region of policy "
  default     = "us-central1"
}

variable "disk_type" {
  type        = string
  description = "The additional_disk_type of the VM."
  default     = "pd-ssd"
}
variable "disk_size" {
  type        = number
  description = "The addtnl_disk_size of the VM."
  default     = 10
}