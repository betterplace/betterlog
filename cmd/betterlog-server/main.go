package main

import (
	"context"
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
	"golang.org/x/crypto/acme/autocert"
)

type Config struct {
	PORT         int    `default:"5514"`
	HEALTHZ_PORT int    `default:"5513"`
	HTTP_REALM   string `default:"betterlog"`
	HTTP_AUTH    string
	SSL          bool
	REDIS_PREFIX string
	REDIS_URL    string `default:"redis://localhost:6379"`
}

type RedisCertCache struct {
	Redis  *redis.Client
	PREFIX string
}

// Get reads certificate data from the specified key name.
func (cache RedisCertCache) Get(ctx context.Context, name string) ([]byte, error) {
	name = strings.Join([]string{cache.PREFIX, name}, "/")
	done := make(chan struct{})
	var (
		err  error
		data string
	)
	go func() {
		defer close(done)
		result := cache.Redis.Get(name)
		err = result.Err()
		if err == nil {
			data, err = result.Result()
		}
	}()
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	case <-done:
	}
	if err == redis.Nil {
		return nil, autocert.ErrCacheMiss
	}
	return []byte(data), err
}

// Put writes the certificate data to the specified redis key name.
func (cache RedisCertCache) Put(ctx context.Context, name string, data []byte) error {
	name = strings.Join([]string{cache.PREFIX, name}, "/")
	done := make(chan struct{})
	var err error
	go func() {
		defer close(done)
		select {
		case <-ctx.Done():
			// Don't overwrite the key if the context was canceled.
		default:
			result := cache.Redis.Set(name, string(data), 0)
			err = result.Err()
		}
	}()
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-done:
	}
	return err
}

// Delete removes the specified key name.
func (cache RedisCertCache) Delete(ctx context.Context, name string) error {
	name = strings.Join([]string{cache.PREFIX, name}, "/")
	var (
		err  error
		done = make(chan struct{})
	)
	go func() {
		defer close(done)
		err = cache.Redis.Del(name).Err()
	}()
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-done:
	}
	return err
}

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

func basicAuthConfig(config Config) middleware.BasicAuthConfig {
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

func initializeRedis(config Config) *redis.Client {
	options, err := redis.ParseURL(config.REDIS_URL)
	if err != nil {
		log.Panic(err)
	}
	options.MaxRetries = 3
	return redis.NewClient(options)
}

func main() {
	var config Config
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
		e.AutoTLSManager.Cache = RedisCertCache{
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
