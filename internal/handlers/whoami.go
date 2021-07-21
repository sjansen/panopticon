package handlers

import (
	"net/http"

	"github.com/crewjam/saml/samlsp"

	"github.com/sjansen/panopticon/internal/authz"
	"github.com/sjansen/panopticon/internal/config"
	"github.com/sjansen/panopticon/internal/pages"
)

// WhoAmI shows information about the current user.
type WhoAmI struct{}

// NewRoot creates a new root page handler.
func NewWhoAmI(cfg *config.Config) *WhoAmI {
	return &WhoAmI{}
}

// WhoAmI shows information about the current user.
func (p *WhoAmI) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var user *authz.User
	s := samlsp.SessionFromContext(r.Context())
	if u, ok := s.(*authz.User); ok {
		user = u
	}

	page := &pages.ProfilePage{}
	page.User = user
	pages.WriteResponse(w, page)
}
