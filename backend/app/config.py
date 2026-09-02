from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List
import os

class Settings(BaseSettings):
    PROJECT_NAME: str = "OSTEOGUARD-NER Backend"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    ENVIRONMENT: str = "development"
    LOG_LEVEL: str = "INFO"
    ENABLE_DEMO_MODE: bool = True
    MODEL_PROVIDER: str = "rule_based" # 'rule_based' or 'tinyml'
    
    # Security
    SECRET_KEY: str = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 # 24 hours for frontline health workers
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    # Database
    DATABASE_URL: str = "sqlite:///./osteoguard.db" # Default fallback for local testing, overridden by PostgreSQL in docker
    
    # CORS
    CORS_ORIGINS: List[str] = ["*"]
    
    # Medical Safety & Risk Engine Thresholds
    MIN_DATA_COMPLETENESS_THRESHOLD: float = 0.80
    RED_FLAG_PAIN_THRESHOLD: int = 8
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="allow"
    )

settings = Settings()
