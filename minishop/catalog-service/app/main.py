from fastapi import FastAPI, HTTPException

app = FastAPI(title="MiniShop Catalog Service")

products = {
    1: {"id": 1, "name": "Laptop", "price": 25000.0},
    2: {"id": 2, "name": "Smartphone", "price": 15000.0},
    3: {"id": 3, "name": "Headphones", "price": 2000.0},
}

@app.get("/health")
def health():
    return {"status": "healthy", "service": "catalog"}

@app.get("/products")
def get_products():
    return list(products.values())

@app.get("/products/{product_id}")
def get_product(product_id: int):
    product = products.get(product_id)
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@app.get("/instance")
def get_instance():
    import socket
    return {"service": "catalog", "hostname": socket.gethostname()}