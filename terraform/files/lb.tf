# Terraform Version
terraform {
  required_version = "0.11.11"
}

# Group
resource "google_compute_instance_group" "instance-group-1" {
  name      = "instance-group-1"
  zone      = "${var.zone}"
  instances = ["${google_compute_instance.app.*.self_link}"]

  named_port {
    name = "http"
    port = 9292
  }
}

# Backend Services
resource "google_compute_backend_service" "lb-back" {
  name        = "lb-back"
  protocol    = "HTTP"
  timeout_sec = "10"

  backend {
    group = "${google_compute_instance_group.instance-group-1.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.lb-healthchk.self_link}"]
}

# Health Check
resource "google_compute_http_health_check" "lb-healthchk" {
  name               = "lb-healthchk"
  request_path       = "/"
  check_interval_sec = 10
  timeout_sec        = 5
  port               = 9292
}

# LB Proxy
resource "google_compute_target_http_proxy" "lb-proxy" {
  name    = "lb-proxy"
  url_map = "${google_compute_url_map.lb.self_link}"
}

# Mapping proxy with backend
resource "google_compute_url_map" "lb" {
  name            = "lb"
  default_service = "${google_compute_backend_service.lb-back.self_link}"
}

# Intarface VM
resource "google_compute_global_address" "lb-ip" {
  name = "lb-ip"
}

resource "google_compute_global_forwarding_rule" "lb-fwd" {
  name       = "lb-fwd"
  port_range = "80"
  ip_address = "${google_compute_global_address.lb-ip.address}"
  target     = "${google_compute_target_http_proxy.lb-proxy.self_link}"
}
