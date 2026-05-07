"""FCM push notification helpers shared across Django apps."""
from __future__ import annotations

import logging
from typing import Sequence

logger = logging.getLogger(__name__)


def _ensure_firebase() -> None:
    """Initialise Firebase Admin SDK if not already done."""
    from apps.common.auth import FirebaseAuthentication  # noqa: PLC0415
    FirebaseAuthentication._initialize_firebase_if_needed()


def send_fcm_push(token: str, title: str, body: str, data: dict | None = None) -> bool:
    """Send a single FCM push notification.  Returns True on success."""
    if not token or not token.strip():
        return False
    try:
        _ensure_firebase()
        from firebase_admin import messaging  # noqa: PLC0415

        msg = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            token=token.strip(),
            android=messaging.AndroidConfig(priority="high"),
        )
        messaging.send(msg)
        return True
    except Exception as exc:  # noqa: BLE001
        logger.warning("FCM send failed for token %s…: %s", token[:20], exc)
        return False


def send_fcm_multicast(tokens: Sequence[str], title: str, body: str, data: dict | None = None) -> int:
    """Send to multiple tokens (skips blanks).  Returns count of successful sends."""
    valid = [t.strip() for t in tokens if t and t.strip()]
    if not valid:
        return 0
    try:
        _ensure_firebase()
        from firebase_admin import messaging  # noqa: PLC0415

        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            tokens=valid,
            android=messaging.AndroidConfig(priority="high"),
        )
        response = messaging.send_each_for_multicast(message)
        return response.success_count
    except Exception as exc:  # noqa: BLE001
        logger.warning("FCM multicast failed: %s", exc)
        return 0
