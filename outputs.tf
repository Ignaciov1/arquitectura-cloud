output "url_balanceador" {
  value       = aws_lb.alb.dns_name
  description = "Copia este DNS en tu navegador para ver la web (Puerto 80) y usar las APIs (3001-3004)"
}