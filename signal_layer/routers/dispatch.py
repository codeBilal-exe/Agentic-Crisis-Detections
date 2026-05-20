from fastapi import APIRouter

from models.dispatch_ticket import AUTHORITY_CONTACTS, DispatchTicket, now_iso
from services.firebase_service import FirebaseService


router = APIRouter()
firebase = FirebaseService()


def _normalize_authority(authority: str) -> str:
    if not authority:
        return "PDMA"
    value = authority.upper().strip()

    if "POLICE" in value:
        return "POLICE"
    if "FIRE" in value:
        return "FIRE"
    if "RESCUE" in value or "1122" in value:
        return "RESCUE_1122"
    if "NDMA" in value:
        return "NDMA"
    if "NHA" in value:
        return "NHA"
    if "HOSPITAL" in value:
        return "HOSPITAL"
    if "PDMA" in value:
        return "PDMA"
    if "EDHI" in value:
        return "EDHI"
    if "CHIPPA" in value:
        return "CHIPPA"

    return value


def _normalize_priority(priority) -> str:
    if isinstance(priority, int):
        if priority <= 1:
            return "P1_IMMEDIATE"
        if priority == 2:
            return "P2_URGENT"
        return "P3_STANDARD"

    value = str(priority or "").upper().strip()
    if value in {"P1_IMMEDIATE", "P2_URGENT", "P3_STANDARD"}:
        return value
    if value in {"1", "HIGH", "CRITICAL"}:
        return "P1_IMMEDIATE"
    if value in {"2", "MEDIUM", "URGENT"}:
        return "P2_URGENT"
    return "P3_STANDARD"


def _normalize_status(ticket: dict) -> str:
    raw_status = str(ticket.get("status", "")).upper().strip()
    if raw_status in {"ISSUED", "ACKNOWLEDGED", "UNITS_DISPATCHED", "ON_SCENE"}:
        return raw_status
    if ticket.get("acknowledged") is True:
        return "ACKNOWLEDGED"
    return "ISSUED"


def _normalize_coordinates(ticket: dict) -> dict:
    coords = ticket.get("coordinates")
    if isinstance(coords, dict) and "lat" in coords and "lng" in coords:
        return {"lat": coords["lat"], "lng": coords["lng"]}

    lat = ticket.get("lat")
    lng = ticket.get("lng")
    if lat is not None and lng is not None:
        return {"lat": lat, "lng": lng}

    return {"lat": 0.0, "lng": 0.0}


def _normalize_ticket(ticket_id: str, raw_ticket: dict) -> DispatchTicket:
    authority = _normalize_authority(
        str(raw_ticket.get("authority") or raw_ticket.get("authority_type") or "PDMA")
    )
    authority_contact = str(
        raw_ticket.get("authority_contact")
        or AUTHORITY_CONTACTS.get(authority, "N/A")
    )

    return DispatchTicket(
        ticket_id=str(raw_ticket.get("ticket_id") or ticket_id),
        crisis_id=str(raw_ticket.get("crisis_id") or "unknown_crisis"),
        authority=authority,
        authority_contact=authority_contact,
        priority=_normalize_priority(raw_ticket.get("priority")),
        incident_type=str(raw_ticket.get("incident_type") or "general_emergency"),
        location=str(raw_ticket.get("location") or "Unknown location"),
        coordinates=_normalize_coordinates(raw_ticket),
        message=str(raw_ticket.get("message") or raw_ticket.get("notification_message") or ""),
        estimated_units_needed=int(raw_ticket.get("estimated_units_needed") or 1),
        issued_by=str(raw_ticket.get("issued_by") or "Commander Agent"),
        issued_at=str(raw_ticket.get("issued_at") or raw_ticket.get("sent_at") or now_iso()),
        status=_normalize_status(raw_ticket),
    )


def _read_all_tickets() -> list[DispatchTicket]:
    raw = firebase.get("dispatch_tickets") or {}
    if not isinstance(raw, dict):
        return []

    tickets: list[DispatchTicket] = []
    for ticket_id, ticket_payload in raw.items():
        if not isinstance(ticket_payload, dict):
            continue
        try:
            tickets.append(_normalize_ticket(ticket_id, ticket_payload))
        except Exception as error:
            print(f"[DispatchRouter] Skipping invalid ticket {ticket_id}: {error}")
    return tickets


@router.get("/tickets")
def get_dispatch_tickets():
    tickets = _read_all_tickets()
    return {
        "count": len(tickets),
        "tickets": [ticket.model_dump() for ticket in tickets],
    }


@router.get("/tickets/{crisis_id}")
def get_dispatch_tickets_by_crisis(crisis_id: str):
    tickets = _read_all_tickets()
    filtered = [ticket for ticket in tickets if ticket.crisis_id == crisis_id]
    return {
        "crisis_id": crisis_id,
        "count": len(filtered),
        "tickets": [ticket.model_dump() for ticket in filtered],
    }

