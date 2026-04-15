import psycopg2
from psycopg2 import pool
from backend.core.config import settings

try:
    connection_pool = psycopg2.pool.SimpleConnectionPool(
        1, 10,
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        dbname=settings.DB_NAME,
        user=settings.DB_USER,
        password=settings.DB_PASSWORD
    )
except Exception as e:
    print(f"Error connecting to database: {e}")
    connection_pool = None

def get_db_connection():
    if not connection_pool:
        raise Exception("Database connection pool is not initialized.")
    conn = connection_pool.getconn()
    try:
        yield conn
    finally:
        connection_pool.putconn(conn)
