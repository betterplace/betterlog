package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"

	betterlog "github.com/betterplace/betterlog/betterlog"
	"github.com/go-redis/redis"
	"github.com/kelseyhightower/envconfig"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func postLogHandler(c echo.Context) error {
	body := c.Request().Body
	data, err := ioutil.ReadAll(body)
	if err == nil {
		defer body.Close()
		os.Stdout.Write(data)
		return c.NoContent(http.StatusOK)
	} else {
		return c.String(http.StatusInternalServerError, err.Error())
	}
}

func basicAuthConfig(config betterlog.Config) middleware.BasicAuthConfig {
	return middleware.BasicAuthConfig{
		Realm: config.HTTP_REALM,
		Validator: func(username, password string, c echo.Context) (bool, error) {
			httpAuth := strings.Split(config.HTTP_AUTH, ":")
			if username == httpAuth[0] && password == httpAuth[1] {
				return true, nil
			}
			return false, nil
		},
	}
}

func initializeRedis(config betterlog.Config) *redis.Client {
	options, err := redis.ParseURL(config.REDIS_URL)
	if err != nil {
		log.Panic(err)
	}
	options.MaxRetries = 3
	return redis.NewClient(options)
}

func main() {
	var config betterlog.Config
	err := envconfig.Process("", &config)
	if err != nil {
		log.Fatal(err)
	}
	e := echo.New()
	if config.HTTP_AUTH != "" {
		fmt.Println("info: Configuring HTTP Auth access control")
		e.Use(middleware.BasicAuthWithConfig(basicAuthConfig(config)))
	}
	e.POST("/log", postLogHandler)
	if config.SSL {
		log.Println("Starting SSL AutoTLS service.")
		redis := initializeRedis(config)
		e.AutoTLSManager.Cache = betterlog.RedisCertCache{
			Redis:  redis,
			PREFIX: config.REDIS_PREFIX,
		}
		go betterlog.StartHealthzEcho(
			betterlog.Health{
				PORT: config.HEALTHZ_PORT,
			})
		e.Logger.Fatal(e.StartAutoTLS(fmt.Sprintf(":%d", config.PORT)))
	} else {
		e.Logger.Fatal(e.Start(fmt.Sprintf(":%d", config.PORT)))
	}
}
