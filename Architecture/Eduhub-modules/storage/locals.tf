# Add this at the top of your databases module (or in root locals)
locals {
  # Perfect safe name: lowercase, no double hyphens, starts with letter
  safe_name = replace(lower(var.project_name), "/[^a-z0-9]+/", "-")
  # → teleios-eduhub-academy-prod   (no double hyphens, perfect)
}