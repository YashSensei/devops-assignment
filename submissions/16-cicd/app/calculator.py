"""Small Session 16 build artifact, inspired by the course calculator exercise."""
def add(a, b):
    return a + b

def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

if __name__ == "__main__":
    print(f"Yash Agrawal 24bcs10164: 12 + 8 = {add(12, 8)}")
