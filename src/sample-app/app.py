import os

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from flask import Flask, jsonify


app = Flask(__name__)

KEY_VAULT_URL = os.environ["KEY_VAULT_URL"]
SECRET_NAME = os.environ.get("SECRET_NAME", "sample-app-message")

credential = DefaultAzureCredential()
secret_client = SecretClient(
    vault_url=KEY_VAULT_URL,
    credential=credential,
)


@app.get("/")
def index():
    try:
        secret = secret_client.get_secret(SECRET_NAME)

        return jsonify(
            status="ok",
            message=secret.value,
            authentication="Azure Workload Identity",
            version="v2",
        )
    except Exception as exc:
        app.logger.exception("Failed to retrieve secret from Key Vault")

        return jsonify(
            status="error",
            error=type(exc).__name__,
        ), 500


@app.get("/health")
def health():
    return jsonify(status="healthy")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)