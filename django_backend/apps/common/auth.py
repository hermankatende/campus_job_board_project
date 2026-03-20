import json
import os

import firebase_admin
from firebase_admin import auth as firebase_auth
from firebase_admin import credentials
from rest_framework import authentication
from rest_framework import exceptions


class FirebaseAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.META.get("HTTP_AUTHORIZATION", "")
        if not auth_header.startswith("Bearer "):
            return None

        id_token = auth_header.split("Bearer ")[1].strip()
        if not id_token:
            raise exceptions.AuthenticationFailed("Missing Firebase token.")

        self._initialize_firebase_if_needed()

        try:
            decoded_token = firebase_auth.verify_id_token(id_token)
        except Exception as exc:
            raise exceptions.AuthenticationFailed(f"Invalid Firebase token: {exc}") from exc

        request.firebase_user = decoded_token
        return (None, decoded_token)

    @staticmethod
    def _initialize_firebase_if_needed() -> None:
        if firebase_admin._apps:
            return

        # Option 1: credentials file path (preferred for local dev and PythonAnywhere)
        credentials_file = os.getenv("FIREBASE_CREDENTIALS_FILE", "")
        if credentials_file:
            if not os.path.isabs(credentials_file):
                credentials_file = os.path.join(
                    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                    credentials_file,
                )
            if os.path.isfile(credentials_file):
                firebase_admin.initialize_app(credentials.Certificate(credentials_file))
                return

        # Option 2: inline JSON string in env var FIREBASE_CREDENTIALS_JSON
        creds_json = os.getenv("FIREBASE_CREDENTIALS_JSON", "")
        if creds_json:
            creds_dict = json.loads(creds_json)
            firebase_admin.initialize_app(credentials.Certificate(creds_dict))
            return

        raise RuntimeError(
            "Firebase credentials not configured. "
            "Set FIREBASE_CREDENTIALS_FILE (path to service-account.json) "
            "or FIREBASE_CREDENTIALS_JSON (JSON string) in your .env file."
        )
