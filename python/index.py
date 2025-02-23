import json
import requests
import sys

def lambda_handler(event, context):
    # Extract query parameters
    query_params = event.get("queryStringParameters", {}) or {}
    api_key = query_params.get("apikey", None)  # API key is required
    movie_title = query_params.get("t", None)  # Movie title parameter
    
    # Validate required parameters
    if not api_key:
        return {
            "statusCode": 400,
            "body": json.dumps({"Response": "False", "Error": "Missing apikey parameter"})
        }
    if not movie_title:
        return {
            "statusCode": 400,
            "body": json.dumps({"Response": "False", "Error": "Missing t parameter (movie title)"})
        }

    # Construct OMDb API URL
    url = f"http://www.omdbapi.com/?t={movie_title}&apikey={api_key}"

    # Make API request
    response = requests.get(url)

    # Handle API response
    return {
        "statusCode": response.status_code,
        "body": json.dumps(response.json())
    }

#TESTING API CALL with URL: https://<URL>?apikey=<APIKEY>&t=300