#output "app_external_ip" {
#  value = "${join(",\n",google_compute_instance.app.*.network_interface.0.access_config.0.nat_ip)}"
#  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.nat_ip}"
#}

#output "load-balancer-ip" {
#  value = "${google_compute_global_forwarding_rule.lb-fwd.ip_address}"
#}

output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}
