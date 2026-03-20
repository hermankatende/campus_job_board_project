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

        credentials_file = os.getenv("FIREBASE_CREDENTIALS_FILE", "service-account.json")
        if not os.path.isabs(credentials_file):
            credentials_file = os.path.join(os.getcwd(), credentials_file)

        firebase_admin.initialize_app(credentials.Certificate(credentials_file))
