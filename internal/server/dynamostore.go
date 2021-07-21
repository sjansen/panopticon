package server

import (
	"time"

	"github.com/alexedwards/scs/v2"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/sjansen/dynamostore"

	"github.com/sjansen/panopticon/internal/config"
)

func (s *Server) openDynamoStores(cfg *config.Config) (scs.Store, scs.Store, error) {
	var svc *dynamodb.Client
	if cfg.Sess.Endpoint.Host == "" {
		svc = dynamodb.NewFromConfig(s.config.AWS.Config)
	} else {
		creds := credentials.NewStaticCredentialsProvider("id", "secret", "token")
		svc = dynamodb.NewFromConfig(
			aws.Config{
				Credentials: creds,
				Region:      "us-west-2",
			},
			dynamodb.WithEndpointResolver(
				dynamodb.EndpointResolverFromURL(
					cfg.Sess.Endpoint.String(),
					func(e *aws.Endpoint) {
						e.HostnameImmutable = true
					},
				),
			),
		)
	}

	store := dynamostore.NewWithTableName(svc, cfg.Sess.Table)
	if cfg.Sess.Create {
		for i := 0; i < 3; i++ {
			if err := store.CreateTable(); err == nil {
				break
			} else if i > 1 {
				return nil, nil, err
			}
			time.Sleep(1 * time.Second)
		}
	}

	relaystate := NewPrefixStore("r:", store)
	sessions := NewPrefixStore("s:", store)
	return relaystate, sessions, nil
}

// PrefixStore enables multiple sessions to be stored in a single
// session store by automatically pre-pending a prefix to tokens.
type PrefixStore struct {
	prefix string
	store  scs.Store
}

// NewPrefixStore wraps a session store so it can be shared.
func NewPrefixStore(prefix string, store scs.Store) *PrefixStore {
	return &PrefixStore{
		prefix: prefix,
		store:  store,
	}
}

// Delete removes the session token and data from the store.
func (s *PrefixStore) Delete(token string) (err error) {
	return s.store.Delete(s.prefix + token)
}

// Find returns the data for a session token from the store.
func (s *PrefixStore) Find(token string) (b []byte, found bool, err error) {
	return s.store.Find(s.prefix + token)
}

// Commit adds the session token and data to the store.
func (s *PrefixStore) Commit(token string, b []byte, expiry time.Time) (err error) {
	return s.store.Commit(s.prefix+token, b, expiry)
}
