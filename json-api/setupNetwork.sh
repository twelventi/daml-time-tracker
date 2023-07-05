

# Start a JSON API Server against your Ledger and Model and showcase how to use the api (dar upload, party allocation, contract creation and exercise) using the curl command and/or Postman.

## Start the server with:
# daml json-api --config json-api.conf

# basic JWT that is unsigned for the purposes of dev on the demo network
AUTHORIZATION="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwczovL2RhbWwuY29tL2xlZGdlci1hcGkiOnsibGVkZ2VySWQiOiJwYXJ0aWNpcGFudDEiLCJhcHBsaWNhdGlvbklkIjoiZGFtbC10aW1lLXRyYWNrZXIiLCJhY3RBcyI6WyJ1c2VyMSJdfX0.HGiHsZL7m6wPUrKlaonQjd7gKZuKOwiDOFA40BSYV3g"

#upload the dar file 
curl -X POST http://localhost:5555/v1/packages -H "Content-Type: application/octet-stream" -H "Authorization: Bearer $AUTHORIZATION" --data-binary @../.daml/dist/daml-time-tracker-0.1.0.dar 

# create a party, user1
curl -X POST http://localhost:5555/v1/parties/allocate -H "Content-Type: application/json" -H "Authorization: Bearer $AUTHORIZATION" -d '{"identifierHint": "user1", "displayName": "user1"}'

# get the full identifier for the party, user1
USER=$(curl -X GET http://localhost:5555/v1/parties -H "Content-Type: application/json" -H "Authorization: Bearer $AUTHORIZATION" | jq .result[].identifier | grep user1 | tr -d '"' )
echo $USER

# create a new jwt for this specific party
PERMS=$( echo '{
  "https://daml.com/ledger-api": {
    "ledgerId": "participant1",
    "applicationId": "daml-time-tracker",
    "actAs": [
      "'$USER'"
    ]
  }
}' | base64 )


#change the jwt to allow user1 to create contract
NEW_AUTH="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$PERMS.HGiHsZL7m6wPUrKlaonQjd7gKZuKOwiDOFA40BSYV3g"

# create a User contract to correspond with the user1 party
curl -X POST http://localhost:5555/v1/create -H "Content-Type: application/json" -H "Authorization: Bearer $NEW_AUTH" -d '{"templateId" : "544d38add2033b86a0175aa916ea0875e4f62874e2065e5efe8ff25881a71b7e:User:User","payload":{"username": "'$USER'"}}'

# get the ID of the contract
CONTRACT_ID=$(curl -X GET http://localhost:5555/v1/query -H "Content-Type: application/json" -H "Authorization: Bearer $NEW_AUTH" -d '{"templateIds" : [ "544d38add2033b86a0175aa916ea0875e4f62874e2065e5efe8ff25881a71b7e:User:User" ]}' | jq .result[0].contractId | tr -d '"')

echo $CONTRACT_ID

# create a time record 
curl -X POST http://localhost:5555/v1/exercise -H "Content-Type: application/json" -H "Authorization: Bearer $NEW_AUTH" -d '
{
    "templateId" : "544d38add2033b86a0175aa916ea0875e4f62874e2065e5efe8ff25881a71b7e:User:User", 
    "contractId":"'$CONTRACT_ID'", 
    "choice": "Create", 
    "argument": {
        "desc": "desc", 
        "proj":"project1",
        "start": "2023-06-21T18:25:43.511Z",
        "end": "2023-06-21T18:26:43.511Z"
    }
}'
