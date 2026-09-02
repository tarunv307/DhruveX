import random
import string
from datetime import datetime

def generate_patient_code(prefix: str = "P") -> str:
    # e.g., P-9842 or DEMO-OANER-001
    rand_num = random.randint(1000, 9999)
    return f"{prefix}-{rand_num}"

def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    if height_cm <= 0:
        return 0.0
    height_m = height_cm / 100.0
    return round(weight_kg / (height_m * height_m), 2)
