import unittest

from fastapi.testclient import TestClient
from app.main import app


class CatalogTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_health(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "healthy")

    def test_products(self):
        response = self.client.get("/products")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json()), 3)

    def test_missing_product(self):
        response = self.client.get("/products/999")
        self.assertEqual(response.status_code, 404)


if __name__ == "__main__":
    unittest.main()