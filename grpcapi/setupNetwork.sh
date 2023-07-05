# this file mirrors some of the functionality in the json api but uses the grpc api

# Do the same as in the previous task but against the Ledger API using grpcurl and/or Postman (a new version which supports gRPC).

# upload the dar file
grpcurl -plaintext -d @ localhost:5011  com.daml.ledger.api.v1.admin.PackageManagementService/UploadDarFile << EOM
{
    "dar_file": "$(cat '../.daml/dist/daml-time-tracker-0.1.0.dar' | base64 )"
}
EOM

#gets the party ID for the user object
USER=$( grpcurl  -d '{"party_id_hint":"user3"}' -plaintext localhost:5011 com.daml.ledger.api.v1.admin.PartyManagementService.AllocateParty | jq .party_details.party | tr -d '"')

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
                        "package_id" : "5a8af51473a4f3502f793754099201c34f7573b7b3d7e375483479f6d5082744",
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
