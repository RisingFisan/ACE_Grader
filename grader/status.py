from enum import Enum

class Status(Enum):
    SUCCESS = 0
    ERROR = 1
    TIMEOUT = 2
    PENDING = -1
    INTERPRETED = -2
