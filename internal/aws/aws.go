package aws

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

// AWS provides configuration for aws-sdk clients.
type AWS struct {
	aws.Config
}

// New uses the aws-sdk prepare default client configs.
func New(ctx context.Context) (*AWS, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}
	return &AWS{
		Config: cfg,
	}, nil
}

// NewSSMClient creates a new aws-sdk S3 client.
func (aws *AWS) NewSSMClient() *ssm.Client {
	return ssm.NewFromConfig(aws.Config)
}
