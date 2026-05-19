import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from routers import signals, crisis, units, simulation

app = FastAPI(title="CIRO Mock Signal Server", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(signals.router, prefix="/api/signals", tags=["Signals"])
app.include_router(crisis.router, prefix="/api/crisis", tags=["Crisis"])
app.include_router(units.router, prefix="/api/units", tags=["Units"])
app.include_router(simulation.router, prefix="/api/simulation", tags=["Simulation"])


@app.get("/")
def root():
    return {"status": "CIRO Mock Server running", "version": "1.0.0"}


@app.get("/dashboard", response_class=HTMLResponse)
def test_dashboard():
    html_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_dashboard.html")
    with open(html_path, "r", encoding="utf-8") as f:
        return f.read()
