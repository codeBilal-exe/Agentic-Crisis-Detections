# CIRO MANAGER — Pipeline Orchestration
## Google Antigravity Manager Surface Instructions

---

### SYSTEM CONFIGURATION

- **BASE_API_URL**: `http://localhost:8000`
- **FIREBASE**: Use `firebase_write` and `firebase_read` tools
- **PIPELINE**: Sentinel → Analyst → Commander → Dispatcher (sequential, strict order)

---

### PIPELINE EXECUTION

#### Phase 1: Signal Collection (Sentinel)
1. Invoke **Agent 1 — The Sentinel**
2. Sentinel calls `GET {BASE_API_URL}/api/signals/all`
3. Sentinel normalizes signals, clusters, cross-corroborates
4. Sentinel produces **SignalBundle JSON** artifact
5. If `SignalBundle.recommended_analyst_action == "DISMISS"`:
   - Log to `/agent_logs`: "No actionable signals detected. Pipeline halted."
   - **STOP pipeline**
6. Pass SignalBundle to Phase 2

#### Phase 2: Crisis Analysis (Analyst)
1. Invoke **Agent 2 — The Analyst** with SignalBundle
2. Analyst scores crisis across 5 dimensions, calculates confidence
3. Analyst produces **CrisisProfile JSON** artifact
4. If Analyst outputs `NO_CRISIS`:
   - Log to `/agent_logs`: "Analyst determined no crisis. Signals assessed as baseline activity."
   - **STOP pipeline**
5. Analyst writes CrisisProfile to Firebase `/active_crises/[crisis_id]`
6. Pass CrisisProfile to Phase 3

#### Phase 3: Response Planning (Commander)
1. Invoke **Agent 3 — The Commander** with CrisisProfile
2. Commander fetches available units from `{BASE_API_URL}/api/units/available`
3. Commander selects protocol, plans actions, generates bilingual alerts
4. Commander produces **ActionPlan JSON** artifact
5. Pass ActionPlan to Phase 4

#### Phase 4: Execution (Dispatcher)
1. Invoke **Agent 4 — The Dispatcher** with ActionPlan
2. Dispatcher validates each action before execution
3. Dispatcher executes Firebase writes in strict 7-step sequence
4. Dispatcher calculates outcome metrics (before → after)
5. Dispatcher produces **ExecutionLog JSON** artifact
6. Pipeline complete

---

### AUTONOMOUS MONITORING LOOP (TASK 1.4 — LIVE SIGNAL MONITORING)

This makes CIRO feel truly autonomous — a continuous feedback loop that judges can watch in real time. CIRO does not just respond once; it **watches, re-assesses, escalates, and resolves** automatically.

After completing one pipeline cycle, if `/system_state/mode == "crisis_active"`:

#### MONITORING CYCLE — Every 90 Seconds

Each cycle has a unique `cycle_id` (format: `cycle_[6char_hex]`) and follows these 6 steps:

**STEP 1 — Sentinel Re-Ingestion (Fresh Signals)**
1. **Wait 90 seconds** from last cycle completion
2. Re-invoke **Agent 1 — The Sentinel** with monitoring context:
   > "MONITORING CYCLE [cycle_number] for ACTIVE CRISIS [crisis_id] at [location]. Previous severity: [severity]. Re-ingest fresh signals from ALL sources. Compare new signal pattern against previous SignalBundle. Flag any new crisis-relevant signals from the same zone."
3. Sentinel calls `GET {BASE_API_URL}/api/signals/all` for fresh data
4. Sentinel produces an **updated SignalBundle** with a `monitoring_cycle` flag set to `true`

**STEP 2 — Signal Comparison & Escalation Detection**
1. Compare new SignalBundle against the **previous cycle's SignalBundle**:
   - Count new signals from the SAME crisis location (within `affected_area.radius_km`)
   - Count new signals from DIFFERENT locations (potential new crises)
   - Check if traffic congestion has increased, decreased, or stabilized
2. Apply **Escalation Detection Rule**:
   - If **3 or more new signals** from the same crisis location: **ESCALATION DETECTED**
   - Log immediately: `"ESCALATION DETECTED: [N] new signals from [location] in cycle [cycle_number]. Situation worsening. Re-scoring crisis."`
   - Set `escalation_flag: true` in the cycle log
3. Apply **New Crisis Detection Rule**:
   - If **3+ signals** from a DIFFERENT location/type: trigger **NEW_CRISIS** pathway (separate pipeline)

**STEP 3 — Analyst Re-Scoring**
1. Pass updated SignalBundle to **Agent 2 — The Analyst** with follow-up context:
   > "MONITORING CYCLE [cycle_number]. This is a follow-up assessment for active crisis [crisis_id]. Previous severity: [severity]. Previous confidence: [confidence]. Previous casualty estimate: [estimate]. New signals received: [N]. Escalation flag: [true/false]. Re-score all 5 dimensions with updated data. Update prediction_timeline (T+15/T+30/T+60) based on elapsed time since initial detection. Determine if crisis is ESCALATING, STABLE, or RESOLVING."
2. Analyst outputs one of these **monitoring verdicts**:

| Verdict | Condition | Action |
|---|---|---|
| **ESCALATION** | 3+ new signals from same zone, OR congestion increasing, OR new casualty reports | Re-run Commander with updated CrisisProfile. Upgrade severity if warranted. Update `prediction_timeline`. |
| **STABLE** | 1-2 new signals, congestion steady, no new casualty reports | Log "Crisis stable, monitoring continues." Update `prediction_timeline` timestamps. Wait 90 seconds. |
| **CRISIS_RESOLVING** | 0 new signals from crisis zone AND traffic congestion normalizing (score dropping below 50) | Trigger **Resolution Detection** (see below). Begin close-out sequence. |
| **NEW_CRISIS** | Signals from a different location/type than active crisis | Create new `crisis_id`. Run FULL pipeline separately for new crisis. Continue monitoring existing crisis. |

**STEP 4 — Commander Re-Assessment (if ESCALATION)**
1. If verdict == ESCALATION:
   - Invoke **Agent 3 — The Commander** with the updated CrisisProfile
   - Commander checks if additional resources are needed (backup units, expanded reroutes, additional authority notifications)
   - Commander generates a **supplementary ActionPlan** with only the NEW actions required
   - Mark supplementary actions with `"source": "monitoring_cycle_[N]"` to distinguish from initial response

**STEP 5 — Dispatcher Executes Additional Actions (if ESCALATION)**
1. If Commander generated supplementary actions:
   - Invoke **Agent 4 — The Dispatcher** with the supplementary ActionPlan
   - Dispatcher executes ONLY the new actions (does NOT re-execute initial actions)
   - Dispatcher updates outcome_metrics with latest values
   - Dispatcher produces an **updated ExecutionLog** referencing the monitoring cycle

**STEP 6 — Log Monitoring Cycle to Firebase**
After every monitoring cycle (regardless of verdict), WRITE to `/monitoring_cycles/[cycle_id]`:

```json
{
  "cycle_id": "cycle_[6char_hex]",
  "cycle_number": 1,
  "crisis_id": "[active crisis_id]",
  "started_at": "[ISO timestamp]",
  "completed_at": "[ISO timestamp]",
  "cycle_duration_seconds": 12,
  "new_signals_count": 4,
  "new_signals_same_location": 3,
  "new_signals_different_location": 1,
  "escalation_detected": true,
  "verdict": "ESCALATION",
  "previous_severity": "HIGH",
  "updated_severity": "CRITICAL",
  "previous_confidence": 0.91,
  "updated_confidence": 0.94,
  "congestion_trend": "increasing",
  "congestion_before_cycle": 38,
  "congestion_after_cycle": 52,
  "actions_generated": 2,
  "actions_executed": 2,
  "prediction_timeline_updated": true,
  "cycle_summary": "Monitoring cycle 1: 3 new flood signals from G-10 zone. ESCALATION DETECTED — severity upgraded HIGH → CRITICAL. Commander dispatched backup Alpha Team. Congestion rising (38% → 52%). Prediction timeline updated. Next cycle in 90 seconds.",
  "next_cycle_scheduled_at": "[ISO timestamp + 90s]"
}
```

Also WRITE agent log for each cycle:
```json
{
  "timestamp": "[now ISO]",
  "agent": "Manager",
  "message": "Monitoring cycle [N] completed for crisis [crisis_id]. Verdict: [verdict]. New signals: [N]. Severity: [previous] → [current]. Next cycle: [timestamp].",
  "data_ref": "[cycle_id]",
  "type": "MONITORING_CYCLE"
}
```

#### MONITORING CYCLE LOOP CONTROL

The monitoring loop continues as long as:
- `/system_state/mode == "crisis_active"` OR `/system_state/mode == "simulation"`
- At least one crisis in `/active_crises` has `status == "active"`

The loop terminates when:
- ALL active crises reach `status == "resolved"` → set `/system_state/mode = "monitoring"`
- A `PIPELINE_HALTED` error is logged
- Manual override via `POST {BASE_API_URL}/api/simulation/reset`

Maximum monitoring cycles per crisis: **40 cycles** (40 × 90s = 60 minutes). After 40 cycles, if crisis is still active, log a `PROLONGED_CRISIS` warning and continue at **5-minute intervals** instead of 90 seconds.

---

### RESOLUTION DETECTION & CLOSE-OUT SEQUENCE

When Analyst outputs **CRISIS_RESOLVING** verdict (0 new signals from crisis zone AND traffic normalizing):

#### Resolution Confirmation Check
Before initiating close-out, verify resolution is genuine (not a signal gap):

1. Check that **at least 2 consecutive monitoring cycles** returned 0 new signals from the crisis zone
2. Check that traffic congestion score is **below 50** and **trending downward**
3. Check that no `ESCALATION` verdict occurred in the last 2 cycles

If all 3 conditions met → **CONFIRMED RESOLUTION**. Begin close-out.
If NOT all met → log `"Resolution check inconclusive. Continuing monitoring."` and wait another cycle.

#### Close-Out Sequence (Dispatcher Executes)

Invoke **Agent 4 — The Dispatcher** with a special `close_out` ActionPlan:

**Step A — Mark Units as Returning to Base**
For each unit with `assigned_crisis_id == [crisis_id]`:
```
UPDATE /units/[unit_id]:
{
  "status": "returning",
  "destination": "[original base_location name]",
  "current_lat": "[base_lat + (current_lat - base_lat) × 0.7]",
  "current_lng": "[base_lng + (current_lng - base_lng) × 0.7]",
  "assigned_crisis_id": null,
  "eta_minutes": 12,
  "last_updated": "[ISO timestamp]"
}
```
After simulated return time, UPDATE status to `"available"`.

**Step B — Clear Active Routes**
For each reroute with `crisis_id == [crisis_id]`:
```
UPDATE /routes/active_reroutes/[reroute_id]:
{
  "status": "cleared",
  "cleared_at": "[ISO timestamp]"
}
```

**Step C — Update Crisis Status**
```
UPDATE /active_crises/[crisis_id]:
{
  "status": "resolved",
  "resolved_at": "[ISO timestamp]",
  "total_monitoring_cycles": [N],
  "resolution_method": "autonomous_detection"
}
```

**Step D — Write Resolution Outcome Metrics**
```
UPDATE /outcome_metrics:
{
  "resolved_at": "[ISO timestamp]",
  "total_response_time_minutes": [time from detected_at to resolved_at in minutes],
  "total_monitoring_cycles": [N],
  "peak_severity": "[highest severity reached during lifecycle]",
  "peak_congestion": [highest congestion during lifecycle],
  "final_congestion": [congestion at resolution],
  "total_actions_executed": [total across initial + monitoring cycles],
  "total_authorities_notified": [count],
  "total_hospitals_alerted": [count],
  "units_deployed_count": [count],
  "resolution_status": "RESOLVED"
}
```

**Step E — Calculate Total Response Time**
```
total_response_time_minutes = (resolved_at - detected_at) in minutes
```
This is the key metric for judges — how fast CIRO resolved the crisis end-to-end.

**Step F — Generate Resolution Report**
Write a comprehensive `resolution_report` to Firebase at `/resolution_reports/[report_id]`:

```json
{
  "report_id": "report_[6char_hex]",
  "crisis_id": "[crisis_id]",
  "crisis_type": "[crisis_type]",
  "location": "[affected_area.name]",
  "generated_at": "[ISO timestamp]",
  "timeline": {
    "crisis_detected_at": "[detected_at]",
    "initial_response_at": "[first action executed_at]",
    "first_unit_dispatched_at": "[dispatch timestamp]",
    "first_authority_notified_at": "[first notify_authority timestamp]",
    "peak_severity_reached_at": "[timestamp of highest severity]",
    "resolution_detected_at": "[CRISIS_RESOLVING verdict timestamp]",
    "resolution_confirmed_at": "[close-out initiation timestamp]",
    "all_units_returned_at": "[last unit status → available]",
    "total_response_time_minutes": 47
  },
  "response_summary": {
    "total_actions_executed": 12,
    "units_dispatched": ["1122-ISB-04", "1122-ISB-01"],
    "authorities_notified": ["Police (Islamabad)", "PDMA Islamabad", "PIMS Hospital"],
    "dispatch_tickets_generated": 3,
    "alerts_broadcast": 1,
    "reroutes_activated": 1,
    "relief_points_opened": 1,
    "monitoring_cycles_completed": 4
  },
  "outcome_impact": {
    "congestion_before": 96,
    "congestion_after": 22,
    "congestion_improvement_percent": 77,
    "stranded_vehicles_before": 35,
    "stranded_vehicles_after": 0,
    "casualties_estimated": { "fatalities": 0, "critical": 4, "minor": 12 },
    "hospital_beds_utilized": 16,
    "people_affected": 4800,
    "recovery_time_without_ciro_hours": 18,
    "recovery_time_with_ciro_minutes": 47
  },
  "prediction_accuracy": {
    "t_plus_15_prediction": "[original prediction]",
    "t_plus_15_actual": "[what actually happened by T+15]",
    "t_plus_30_prediction": "[original prediction]",
    "t_plus_30_actual": "[what actually happened by T+30 — was cascading failure prevented?]",
    "prediction_accuracy_assessment": "CIRO's T+15 prediction of flood radius expansion was confirmed by monitoring cycle 2. T+30 power outage prediction was PREVENTED by early IESCO notification. Proactive intelligence demonstrably reduced impact."
  },
  "resolution_narrative": "Crisis [crisis_type] at [location] was detected at [time], with initial severity [severity]. CIRO deployed [N] rescue units within [ETA] minutes, notified [N] authorities, and rerouted traffic via [route]. Over [N] monitoring cycles spanning [M] minutes, CIRO autonomously tracked the crisis progression — [escalation/stable details]. Resolution was autonomously detected when new signals dropped to 0 and traffic congestion normalized to [N]%. Total response time: [M] minutes. Without CIRO, estimated recovery would have taken [X] hours. All units have returned to base. System returned to monitoring mode."
}
```

**Step G — Update System State**
```
UPDATE /system_state:
{
  "mode": "monitoring",
  "active_crisis_count": [total active - 1],
  "last_updated": "[ISO timestamp]",
  "last_resolved_crisis_id": "[crisis_id]",
  "last_resolution_time_minutes": [total_response_time_minutes]
}
```

**Step H — Final Agent Log**
```json
{
  "timestamp": "[now ISO]",
  "agent": "Manager",
  "message": "CRISIS RESOLVED: [crisis_id] ([crisis_type] at [location]). Total response time: [M] minutes. [N] monitoring cycles completed. [N] actions executed. [N] authorities engaged. All units returning to base. System mode: monitoring. Resolution report: [report_id].",
  "data_ref": "[report_id]",
  "type": "CRISIS_RESOLVED"
}
```

---

### MULTI-CRISIS HANDLING

If Analyst detects a DIFFERENT location crisis than the one already active:
1. Create a **new** `crisis_id` (do NOT reuse existing)
2. Commander generates a **SEPARATE** ActionPlan (do not modify existing crisis actions)
3. Dispatcher executes WITHOUT touching existing crisis Firebase state
4. Update `/system_state/active_crisis_count` to reflect total active crises
5. Each crisis maintains independent lifecycle (active → resolved)

---

### PIPELINE ERROR RECOVERY

#### Agent Failure
1. If any agent fails to produce valid output:
   - Log error to `/agent_logs`: `{agent: "[name]", message: "ERROR: [description]", timestamp: "[now]"}`
   - Attempt **retry ONCE** with the same input
   - If retry also fails: log `PIPELINE_HALTED` and set `/system_state/mode = "monitoring_error"`
   - Do NOT proceed to next agent without valid output from current agent

#### Firebase Write Failure
1. If a Firebase write fails:
   - Log the failed path and data to `/agent_logs`
   - Continue with remaining actions
   - Mark `overall_status` as `"PARTIAL"` instead of `"COMPLETE"`
   - Include failed paths in ExecutionLog

#### API Endpoint Unreachable
1. If `{BASE_API_URL}/api/signals/all` is unreachable:
   - Log connection error to `/agent_logs`
   - Set `/system_state/signal_ingestion_active = false`
   - **HALT pipeline** — cannot proceed without signal data

---

### AGENT TRACE ARTIFACT

After full pipeline completion (including resolution), write a markdown artifact:

**Filename:** `CIRO_Agent_Trace_[timestamp].md`

**Contents:**
```markdown
# CIRO Agent Trace — [Crisis Type] at [Location]
## Generated: [timestamp]
## Pipeline Duration: [total seconds]s
## Total Response Time: [total_response_time_minutes] minutes

### Crisis Summary
- Type: [crisis_type]
- Location: [affected_area name]
- Severity: [initial severity] → [peak severity]
- Confidence: [confidence] ([confidence_label])
- Status: [active/resolved]

### SENTINEL OUTPUT
**Assessment:** [sentinel_assessment]
**Signals Processed:** [signal_count] total, [crisis_signals_count] crisis-relevant
**Corroboration Level:** [corroboration_level]
**Signal Bundle:**
[Full SignalBundle JSON]

### ANALYST REASONING
**Severity Score:** [total score] / 15 → [severity]
**Confidence:** [confidence] ([confidence_label])
**Reasoning Summary:** [reasoning_summary]
**Escalation Prediction:** [escalation_prediction]
**Prediction Timeline:**
- T+15: [t_plus_15 prediction]
- T+30: [t_plus_30 prediction]
- T+60: [t_plus_60 prediction]
**Resource Conflict:** [conflict_detected: true/false, details if true]
**Crisis Profile:**
[Full CrisisProfile JSON]

### COMMANDER PLAN
**Protocol:** [response_protocol]
**Brief:** [commander_brief]
**Actions:** [count] actions planned
**Authorities Notified:** [list of authorities with ticket_ids]
**Hospital Routing:** [primary hospital, beds requested, backup]
**Action Plan:**
[Full ActionPlan JSON]

### DISPATCHER EXECUTION
**Status:** [overall_status]
**Narrative:** [simulation_summary]
**Firebase Paths Updated:** [list of all paths written]
**Execution Log:**
[Full ExecutionLog JSON]

### MONITORING CYCLES (AUTONOMOUS LOOP)
**Total Cycles Completed:** [N]
**Escalations Detected:** [count]
**Cycle Log:**
| Cycle | Verdict | New Signals | Severity | Congestion Trend | Actions |
|---|---|---|---|---|---|
| 1 | ESCALATION | 3 | HIGH → CRITICAL | increasing (38→52) | 2 |
| 2 | STABLE | 1 | CRITICAL | steady (52→50) | 0 |
| 3 | CRISIS_RESOLVING | 0 | CRITICAL | decreasing (50→35) | 0 |
| 4 | CRISIS_RESOLVING | 0 | CRITICAL | decreasing (35→22) | 0 |

**Prediction Accuracy:**
- T+15 Prediction: [original] → Actual: [what happened]
- T+30 Prediction: [original] → Actual: [what happened]
- Assessment: [was CIRO's proactive intelligence accurate?]

### RESOLUTION REPORT
**Resolution Method:** autonomous_detection
**Total Response Time:** [M] minutes
**Recovery Comparison:** Without CIRO: [X] hours | With CIRO: [M] minutes
**Outcome Impact:**
- Congestion: [before]% → [after]% ([improvement]% improvement)
- Stranded Vehicles: [before] → [after]
- Casualties: [fatalities] fatalities, [critical] critical, [minor] minor
- Authorities Engaged: [count]
- Hospitals Alerted: [count]
**Resolution Narrative:** [resolution_narrative from resolution_report]

### PIPELINE METRICS
- Agents Completed: [N]/4
- Firebase Paths Updated: [count]
- Total Execution Time: [seconds]s
- Monitoring Cycles: [count]
- Outcome: Congestion [before]% → [after]%, Stranded Vehicles [before] → [after]
- Total Response Time: [M] minutes (detection to resolution)
```

This artifact serves as the complete audit trail for the crisis response — from initial detection through autonomous monitoring to final resolution. Store it for judges to review.
