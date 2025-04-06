resource "aws_dynamodb_table" "search_results" {
  name         = "SearchResultsTable"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "name"
    type = "S"  # String (Partition Key)
  }

  attribute {
    name = "favorite_movie"
    type = "S"  # String (Sort Key)
  }

  hash_key  = "name"
  range_key = "favorite_movie"

}
