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

### CONTINUOUS MONITORING MODE

After completing one pipeline cycle, if `/system_state/mode == "crisis_active"`:

1. **Wait 90 seconds**
2. Re-run **Sentinel** with context:
   > "ONGOING CRISIS [crisis_id] already active at [location]. Assess whether situation has worsened, improved, or new crisis emerged. Compare new signal pattern against previous assessment."
3. Pass updated SignalBundle to **Analyst** with context:
   > "This is a follow-up assessment for active crisis [crisis_id]. Previous severity: [severity]. Previous confidence: [confidence]. Determine if escalation is needed."
4. Analyst outputs one of:
   - **ESCALATION**: Situation worsening → Commander generates additional actions (backup units, expanded reroutes)
   - **STABLE**: No significant change → Log "Crisis stable, monitoring continues" and wait another 90 seconds
   - **RESOLVED**: Crisis subsiding (congestion dropping, no new signals) → Dispatcher updates `/active_crises/[id]/status = "resolved"` and `/system_state/mode = "monitoring"`
   - **NEW_CRISIS**: Different location/type detected → Create new `crisis_id`, run FULL pipeline separately

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

After full pipeline completion, write a markdown artifact:

**Filename:** `CIRO_Agent_Trace_[timestamp].md`

**Contents:**
```markdown
# CIRO Agent Trace — [Crisis Type] at [Location]
## Generated: [timestamp]
## Pipeline Duration: [total seconds]s

### Crisis Summary
- Type: [crisis_type]
- Location: [affected_area name]
- Severity: [severity]
- Confidence: [confidence] ([confidence_label])

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
**Crisis Profile:**
[Full CrisisProfile JSON]

### COMMANDER PLAN
**Protocol:** [response_protocol]
**Brief:** [commander_brief]
**Actions:** [count] actions planned
**Action Plan:**
[Full ActionPlan JSON]

### DISPATCHER EXECUTION
**Status:** [overall_status]
**Narrative:** [simulation_summary]
**Firebase Paths Updated:** [list of all paths written]
**Execution Log:**
[Full ExecutionLog JSON]

### PIPELINE METRICS
- Agents Completed: [N]/4
- Firebase Paths Updated: [count]
- Total Execution Time: [seconds]s
- Outcome: Congestion [before]% → [after]%, Stranded Vehicles [before] → [after]
```

This artifact serves as the complete audit trail for the crisis response. Store it for judges to review.
