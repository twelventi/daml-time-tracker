# this file mirrors the functionality in the json api but uses the grpc api



# Start a JSON API Server against your Ledger and Model and showcase how to use the api (dar upload, party allocation, contract creation and exercise) using the curl command and/or Postman.

## Start the server with:
# daml json-api --config json-api.conf

grpcurl -plaintext -d @ localhost:5011  com.daml.ledger.api.v1.admin.PackageManagementService/UploadDarFile << EOM
{
    "dar_file": "$(cat '../.daml/dist/daml-time-tracker-0.1.0.dar' | base64 )"
}
EOM

#gets the party ID for the user object
USER=$( grpcurl  -d '{"party_id_hint":"user1"}' -plaintext localhost:5011 com.daml.ledger.api.v1.admin.PartyManagementService.AllocateParty | jq .party_details.party | tr -d '"')

# creates a user object 
grpcurl -plaintext -d @ localhost:5011 com.daml.ledger.api.v1.CommandService/SubmitAndWait <<EOM
{
  "commands":
    {
        "application_id" : "daml-time-tracker",
        "command_id" : "create-a-user",
        "act_as" : "$USER",
        "commands":
        [
            {
                "create": {
                    "template_id": {
                        "package_id" : "544d38add2033b86a0175aa916ea0875e4f62874e2065e5efe8ff25881a71b7e",
                        "module_name" : "User",
                        "entity_name": "User"
                    },
                    "create_arguments": {
                        "fields" : [
                            {
                                "label":"username",
                                "value": {
                                    "party" : "$USER"
                                }
                            }
                        ]
                    }
                }
            } 
        ]
    }
}
EOM
