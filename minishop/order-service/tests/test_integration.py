import os
import unittest

import httpx
from fastapi.testclient import TestClient
from app.main import app


class OrderIntegrationTests(unittest.TestCase):
    def test_order_uses_catalog(self):
        catalog_url = os.environ["CATALOG_URL"]
        product = httpx.get(f"{catalog_url}/products/1", timeout=3.0)
        self.assertEqual(product.status_code, 200)

        response = TestClient(app).post(
            "/orders", json={"product_id": 1, "quantity": 2}
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json()["total_price"], 50000.0)


if __name__ == "__main__":
    unittest.main()