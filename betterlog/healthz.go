package bime

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/labstack/echo"
)

type Health struct {
	PORT int
}

type Response struct {
	Hostname string `json:"hostname"`
	Healthy  bool   `json:"healthy"`
	Error    string `json:"error,omitempty"`
	Message  string `json:"message,omitempty"`
}

func determineHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}
	return hostname
}

func (health Health) Check() error {
	return nil
}

func (health Health) ZPage(next echo.HandlerFunc) echo.HandlerFunc {
	hostname := determineHostname()
	return func(c echo.Context) error {
		if c.Path() == "/healthz" {
			if err := health.Check(); err == nil {
				return c.JSON(
					http.StatusOK,
					Response{
						Hostname: hostname,
						Healthy:  true,
					},
				)
			} else {
				log.Printf("error: %v", err)
				return c.JSON(
					http.StatusInternalServerError,
					Response{
						Hostname: hostname,
						Healthy:  false,
						Error:    err.Error(),
						Message:  "problem detected",
					},
				)
			}
		} else {
			return next(c)
		}
	}
}

func StartHealthzEcho(health Health) {
	e := echo.New()

	e.Use(health.ZPage)
	log.Printf("Starting :%d/healthz", health.PORT)
	e.Logger.Fatal(e.Start(fmt.Sprintf(":%d", health.PORT)))
}
