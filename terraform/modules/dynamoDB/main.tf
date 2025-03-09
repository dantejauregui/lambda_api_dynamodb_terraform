resource "aws_dynamodb_table" "search_results" {
  name         = "SearchResultsTable"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "search"
    type = "S"  # String (Partition Key)
  }

  attribute {
    name = "result"
    type = "S"  # String (Sort Key)
  }

  hash_key  = "search"
  range_key = "result"

  tags = {
    Name        = "SearchResultsTable"
    Environment = "Production"
  }
}
