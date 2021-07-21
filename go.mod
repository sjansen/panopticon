module github.com/sjansen/panopticon

go 1.16

require (
	github.com/alexedwards/scs/v2 v2.4.0
	github.com/aws/aws-lambda-go v1.25.0
	github.com/aws/aws-sdk-go-v2 v1.7.1
	github.com/aws/aws-sdk-go-v2/config v1.5.0
	github.com/aws/aws-sdk-go-v2/credentials v1.3.1
	github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue v1.1.3 // indirect
	github.com/aws/aws-sdk-go-v2/service/dynamodb v1.4.1
	github.com/aws/aws-sdk-go-v2/service/ssm v1.8.0
	github.com/awslabs/aws-lambda-go-api-proxy v0.10.0
	github.com/crewjam/saml v0.4.5
	github.com/go-chi/chi v4.1.2+incompatible
	github.com/sjansen/dynamostore v0.0.0-20210313230354-f852e39fad36
	github.com/vrischmann/envconfig v1.3.0
)
