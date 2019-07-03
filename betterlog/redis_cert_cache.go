package betterlog

import (
	"context"
	"strings"

	"github.com/go-redis/redis"
	"golang.org/x/crypto/acme/autocert"
)

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
