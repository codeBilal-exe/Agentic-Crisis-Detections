from datetime import datetime

from pydantic import BaseModel


class DispatchTicket(BaseModel):
    ticket_id: str  # TICKET_[6char_hex]
    crisis_id: str
    authority: str  # POLICE / FIRE / PDMA / NDMA / NHA / HOSPITAL
    authority_contact: str  # Emergency number
    priority: str  # P1_IMMEDIATE / P2_URGENT / P3_STANDARD
    incident_type: str
    location: str
    coordinates: dict  # lat, lng
    message: str  # Formal dispatch message
    estimated_units_needed: int
    issued_by: str  # Commander Agent
    issued_at: str
    status: str  # ISSUED / ACKNOWLEDGED / UNITS_DISPATCHED / ON_SCENE


AUTHORITY_CONTACTS = {
    "POLICE": "15",
    "FIRE": "16",
    "RESCUE_1122": "1122",
    "PDMA": "0800-02345",
    "NDMA": "1700",
    "EDHI": "115",
    "CHIPPA": "1020",
}


def now_iso() -> str:
    return datetime.utcnow().isoformat() + "Z"

