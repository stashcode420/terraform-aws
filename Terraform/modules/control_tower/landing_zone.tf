# modules/control_tower/landing_zone.tf
resource "aws_controltower_landing_zone" "main" {
  depends_on = [
    # aws_organizations_organization.main,
    aws_iam_role.control_tower_admin,
    aws_iam_service_linked_role.control_tower
  ]

  manifest_json = file("${path.module}/LandingZoneManifest.json")
  version       = "3.2"
}