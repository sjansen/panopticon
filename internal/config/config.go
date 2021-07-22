package config

import (
	"context"
	"strings"

	"github.com/aws/aws-sdk-go-v2/service/ssm"
	"github.com/vrischmann/envconfig"

	"github.com/sjansen/panopticon/internal/aws"
)

// Config contains application settings.
type Config struct {
	aws.AWS `envconfig:"-"`

	AppURL *URL   `envconfig:"PANOPTICON_APP_URL"`
	Listen string `envconfig:"PANOPTICON_LISTEN,optional"`

	Development bool   `envconfig:"PANOPTICON_DEVELOPMENT,default=false"`
	SSMPrefix   string `envconfig:"PANOPTICON_SSM_PREFIX,optional"`

	CF   CloudFront
	Sess SessionStore
	SAML SAML
}

// CloudFront contains settings for the app CDN.
type CloudFront struct {
	KeyID      string     `envconfig:"PANOPTICON_CLOUDFRONT_KEY_ID"`
	PrivateKey PrivateKey `envconfig:"PANOPTICON_CLOUDFRONT_PRIVATE_KEY"`
	URL        URL        `envconfig:"PANOPTICON_CLOUDFRONT_URL,default=/"`
}

// SAML contains settings for SAML-based authentication.
type SAML struct {
	EntityID    string `envconfig:"PANOPTICON_SAML_ENTITY_ID,default=panopticon"`
	MetadataURL string `envconfig:"PANOPTICON_SAML_METADATA_URL"`
	Certificate string `envconfig:"PANOPTICON_SAML_CERTIFICATE"`
	PrivateKey  string `envconfig:"PANOPTICON_SAML_PRIVATE_KEY"`
}

// SessionStore contains setting for app sessions.
type SessionStore struct {
	Create   bool   `envconfig:"PANOPTICON_SESSION_CREATE,default=false"`
	Endpoint URL    `envconfig:"PANOPTICON_SESSION_ENDPOINT,optional"`
	Table    string `envconfig:"PANOPTICON_SESSION_TABLE"`
}

// Load reads settings from the environment.
func Load(ctx context.Context) (*Config, error) {
	cfg := &Config{}

	if err := envconfig.Init(&cfg); err != nil {
		return nil, err
	}

	aws, err := aws.New(ctx)
	if err != nil {
		return nil, err
	}
	cfg.AWS.Config = aws.Config

	if cfg.SSMPrefix != "" {
		err = cfg.readSecrets(ctx, aws.NewSSMClient())
		if err != nil {
			return nil, err
		}
	}

	return cfg, nil
}

func (cfg *Config) readSecrets(ctx context.Context, svc *ssm.Client) error {
	resp, err := svc.GetParameters(ctx, &ssm.GetParametersInput{
		Names: []string{
			cfg.SSMPrefix + "CLOUDFRONT_KEY_ID",
			cfg.SSMPrefix + "CLOUDFRONT_PRIVATE_KEY",
			cfg.SSMPrefix + "SAML_CERTIFICATE",
			cfg.SSMPrefix + "SAML_METADATA_URL",
			cfg.SSMPrefix + "SAML_PRIVATE_KEY",
		},
		WithDecryption: true,
	})
	if err != nil {
		return err
	}

	for _, param := range resp.Parameters {
		name := strings.TrimPrefix(*param.Name, cfg.SSMPrefix)
		switch name {
		case "CLOUDFRONT_KEY_ID":
			cfg.CF.KeyID = *param.Value
		case "CLOUDFRONT_PRIVATE_KEY":
			if err := cfg.CF.PrivateKey.Unmarshal(*param.Value); err != nil {
				return err
			}
		case "SAML_CERTIFICATE":
			cfg.SAML.Certificate = *param.Value
		case "SAML_METADATA_URL":
			cfg.SAML.MetadataURL = *param.Value
		case "SAML_PRIVATE_KEY":
			cfg.SAML.PrivateKey = *param.Value
		}
	}
	return nil
}
