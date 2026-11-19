from flask import Flask

app = Flask(__name__)


@app.route("/")
@app.route("/home")
def home():
    return "Hello from Flask! Version 2 deployed with Terraform."


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
