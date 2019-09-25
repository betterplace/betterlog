package betterlog

type Config struct {
	PORT         int    `default:"5514"`
	HEALTHZ_PORT int    `default:"5513"`
	HTTP_REALM   string `default:"betterlog"`
	HTTP_AUTH    string
	SSL          bool
	REDIS_PREFIX string
	REDIS_URL    string `default:"redis://localhost:6379"`
}
