package server

import (
	"net/http"
	"time"

	"github.com/go-chi/chi"
	cmw "github.com/go-chi/chi/middleware"

	"github.com/sjansen/panopticon/internal/handlers"
)

func (s *Server) addRoutes() {
	r := chi.NewRouter()
	s.router = r

	r.Use(
		cmw.RequestID,
		cmw.RealIP,
		cmw.Logger,
		cmw.Recoverer,
		cmw.Timeout(5*time.Second),
		cmw.Heartbeat("/ping"),
		s.sess.LoadAndSave,
		s.relaystate.LoadAndSave,
	)

	requireLogin := s.saml.RequireAccount
	r.Method("GET", "/", requireLogin(
		handlers.NewRoot(s.config),
	))
	r.Method("GET", "/whoami/", requireLogin(
		handlers.NewWhoAmI(s.config),
	))
	r.Mount("/saml/", s.saml)

	if s.config.Development {
		r.Get("/favicon.ico",
			http.StripPrefix("/",
				http.FileServer(http.Dir("terraform/modules/app/icons/")),
			).ServeHTTP,
		)
	}
}
