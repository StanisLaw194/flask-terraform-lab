import unittest
from unittest.mock import Mock, patch

from fastapi.testclient import TestClient
from app.main import app, orders


class OrderTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        orders.clear()

    def test_health(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)

    def test_invalid_quantity(self):
        response = self.client.post(
            "/orders", json={"product_id": 1, "quantity": 0}
        )
        self.assertEqual(response.status_code, 422)

    @patch("app.main.httpx.get")
    def test_create_order(self, mock_get):
        product_response = Mock()
        product_response.json.return_value = {
            "id": 1, "name": "Laptop", "price": 25000.0
        }
        mock_get.return_value = product_response

        response = self.client.post(
            "/orders", json={"product_id": 1, "quantity": 2}
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json()["total_price"], 50000.0)


if __name__ == "__main__":
    unittest.main()