import importlib.util
from pathlib import Path
import pytest
spec = importlib.util.spec_from_file_location("calculator", Path(__file__).parents[1] / "app/calculator.py")
calculator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(calculator)

def test_add():
    assert calculator.add(12, 8) == 20

def test_division():
    assert calculator.divide(12, 4) == 3

def test_zero():
    with pytest.raises(ValueError):
        calculator.divide(1, 0)
