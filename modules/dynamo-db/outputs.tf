output "dynamo_table_name" {
  value = aws_dynamodb_table.db.name
}

output "db_table_arn" {
  value = aws_dynamodb_table.db.arn
}
