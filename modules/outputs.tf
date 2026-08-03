output "myprojectlink" {
  value = "https://${module.api_gw.rest_api_id}.execute-api.us-east-1.amazonaws.com/${module.api_gw.api_stage_name}/shorten"
}
