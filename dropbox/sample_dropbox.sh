#!/bin/bash

MYTOKEN='sl.Af4VpgcaNPQCjddckBVlYz64yU8yYmgWC2tQJWghV12cFjPHs5ZoZ-glnjSRnOVAHFNR8OtbbNYDUKQhJWK7rwAwRcUfsC3Q3QJZpY2VMvJPqWTUOxYfgG1I4qKcPCHxg3ok3wAVsg'

echo "some content here" > testfile.txt

curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $MYTOKEN" \
	--header "Dropbox-API-Arg: {\"path\": \"/Internal Backup/Matrices.txt\"}" \
	--header "Content-Type: application/octet-stream" \
	--header "Dropbox-API-Select-User: support@velocityglobal.co.nz" \
	--data-binary @testfile.txt
