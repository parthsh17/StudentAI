import redis
from backend.core.config import settings

class RedisCache:
    def __init__(self):
        self.host = settings.REDIS_HOST
        self.port = settings.REDIS_PORT
        self.password = settings.REDIS_PASSWORD or None
        self.client = None

    def connect(self):
        try:
            self.client = redis.Redis(
                host=self.host,
                port=self.port,
                password=self.password,
                decode_responses=True,
                socket_connect_timeout=5
            )
            # Test connection
            self.client.ping()
            print(f"Connected to Redis at {self.host}:{self.port}")
        except Exception as e:
            print(f"Warning: Could not connect to Redis: {e}")
            self.client = None

    def get(self, key: str):
        if self.client:
            try:
                return self.client.get(key)
            except Exception:
                pass
        return None

    def set(self, key: str, value: str, ex: int = 300):
        if self.client:
            try:
                self.client.set(key, value, ex=ex)
            except Exception:
                pass

redis_cache = RedisCache()
