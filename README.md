# RetainIQ — Value-Based Retention Decision Engine

> **Go beyond churn prediction. Prioritize retention interventions by expected incremental value.**

[![Python](https://img.shields.io/badge/Python-3.11%2B-3776AB?logo=python\&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-API-009688?logo=fastapi\&logoColor=white)](https://fastapi.tiangolo.com/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker\&logoColor=white)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**RetainIQ is a retention decisioning system that goes beyond conventional churn prediction.**

Instead of simply identifying customers who are likely to churn, RetainIQ estimates **which customers are likely to respond to a retention intervention**, combines treatment uplift with customer value and intervention cost, and produces a **capacity-constrained next-best-action queue**.

---

# 🎯 Business Problem

Traditional churn systems usually answer one question:

> **Who is likely to leave?**

But that is not necessarily the same as:

> **Who should the business actually contact?**

A customer with a high churn probability may:

* be unlikely to respond to an intervention;
* have relatively low customer value;
* cost more to retain than the value expected to be protected;
* consume limited outreach capacity that could be used more effectively elsewhere.

RetainIQ separates these decisions:

```text
Who may churn?
      ↓
Who can be influenced?
      ↓
What value could be protected?
      ↓
Where should limited retention effort be spent?
```

This turns a standard churn prediction problem into a **decisioning problem**.

---

# 🧠 Core Idea

RetainIQ keeps **prediction** and **decisioning** separate.

### 1. Churn Risk

A logistic classifier estimates:

> **Who is likely to churn?**

The output is a customer-level churn probability.

### 2. Treatment Effect

A T-learner estimates the difference between the expected outcome under treatment and control.

```text
Estimated Uplift
=
Expected outcome with intervention
−
Expected outcome without intervention
```

This answers:

> **Who is likely to be influenced by the intervention?**

### 3. Expected Protected Value

Positive uplift is converted into expected protected recurring revenue:

```text
Expected Protected MRR
=
max(Uplift, 0) × MRR
```

### 4. Expected Net Value

Intervention cost is incorporated:

```text
Expected Net Value
=
Expected Protected MRR
−
Action Cost
```

### 5. Capacity-Constrained Decisioning

The policy:

1. removes negative-uplift candidates;
2. removes negative-value candidates;
3. ranks eligible customers by expected net value;
4. applies the available outreach capacity.

The result is a **next-best-action queue**, rather than a simple churn leaderboard.

---

# 🏗️ System Architecture

```mermaid
flowchart TD

    A["👤 Account Signals"] --> B["Feature Processing"]

    B --> C["🎯 Churn Model<br/>Logistic Regression"]
    B --> D["🧪 Treatment Effect Model<br/>T-Learner"]

    C --> E["Churn Probability"]
    D --> F["Estimated Uplift"]

    E --> G["💰 Value Engine"]
    F --> G

    G --> H["Expected Protected MRR"]
    H --> I["− Action Cost"]

    I --> J["Expected Net Value"]

    J --> K{"Policy Gates"}

    K -->|"Positive uplift<br/>Positive value"| L["Eligible Accounts"]
    K -->|"Negative uplift/value"| M["Excluded"]

    L --> N["Rank by Expected Net Value"]
    N --> O["Apply Outreach Capacity"]
    O --> P["🎯 Next-Best-Action Queue"]

    P --> Q["FastAPI Service"]
    Q --> R["RetainIQ Interface"]

    style A fill:#EFF6FF,stroke:#3B82F6,stroke-width:2px,color:#111827
    style B fill:#EEF2FF,stroke:#6366F1,stroke-width:2px,color:#111827
    style C fill:#ECFDF5,stroke:#10B981,stroke-width:2px,color:#111827
    style D fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px,color:#111827
    style E fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#111827
    style F fill:#FDE68A,stroke:#D97706,stroke-width:2px,color:#111827
    style G fill:#F3E8FF,stroke:#8B5CF6,stroke-width:2px,color:#111827
    style H fill:#EDE9FE,stroke:#7C3AED,stroke-width:2px,color:#111827
    style I fill:#FEE2E2,stroke:#EF4444,stroke-width:2px,color:#111827
    style J fill:#EDE9FE,stroke:#6D28D9,stroke-width:3px,color:#111827
    style K fill:#FFF7ED,stroke:#EA580C,stroke-width:2px,color:#111827
    style L fill:#DCFCE7,stroke:#059669,stroke-width:2px,color:#111827
    style M fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#111827
    style N fill:#E0F2FE,stroke:#0284C7,stroke-width:2px,color:#111827
    style O fill:#DBEAFE,stroke:#2563EB,stroke-width:2px,color:#111827
    style P fill:#DBEAFE,stroke:#1D4ED8,stroke-width:3px,color:#111827
    style Q fill:#CFFAFE,stroke:#0891B2,stroke-width:2px,color:#111827
    style R fill:#FCE7F3,stroke:#DB2777,stroke-width:2px,color:#111827
```

---

# 🔄 End-to-End Decision Pipeline

```mermaid
flowchart TD

    A["Raw Account Data"] --> B["Stratified Train / Holdout Split"]

    B --> C["Churn Risk Model"]
    B --> D["Treatment Assignment"]

    D --> E["T-Learner"]

    E --> F["Estimated Treatment Effect"]

    C --> G["Churn Risk"]
    F --> H["Uplift"]

    G --> I["Business Value Layer"]
    H --> I

    I --> J["Protected MRR"]
    I --> K["Action Cost"]

    J --> L["Expected Net Value"]
    K --> L

    L --> M{"Decision Policy"}

    M -->|"Uplift > 0<br/>Net Value > 0"| N["Eligible"]
    M -->|"Otherwise"| O["Excluded"]

    N --> P["Rank by Net Value"]
    P --> Q["Capacity Constraint"]
    Q --> R["Next-Best-Action Queue"]

    style A fill:#E5E7EB,stroke:#6B7280,stroke-width:2px,color:#111827
    style B fill:#DBEAFE,stroke:#2563EB,stroke-width:2px,color:#111827
    style C fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#111827
    style D fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#111827
    style E fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#111827
    style F fill:#FDE68A,stroke:#D97706,stroke-width:2px,color:#111827
    style G fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#111827
    style H fill:#FDE68A,stroke:#D97706,stroke-width:2px,color:#111827
    style I fill:#F3E8FF,stroke:#8B5CF6,stroke-width:2px,color:#111827
    style L fill:#EDE9FE,stroke:#7C3AED,stroke-width:3px,color:#111827
    style M fill:#FFF7ED,stroke:#EA580C,stroke-width:2px,color:#111827
    style N fill:#DCFCE7,stroke:#059669,stroke-width:2px,color:#111827
    style O fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#111827
    style P fill:#E0F2FE,stroke:#0284C7,stroke-width:2px,color:#111827
    style Q fill:#DBEAFE,stroke:#2563EB,stroke-width:2px,color:#111827
    style R fill:#DBEAFE,stroke:#1D4ED8,stroke-width:3px,color:#111827
```

---

# ⚖️ Risk-Only vs Value-Aware Targeting

RetainIQ intentionally includes a risk-only baseline so the decision policy can be compared with a conventional churn-targeting strategy.

### Risk-only

```text
Churn Probability
        ↓
Rank Customers
        ↓
Select Highest Risk
        ↓
Apply Capacity
```

### Value-aware

```text
Churn Risk
    +
Treatment Uplift
    +
Customer Value
    −
Action Cost
    ↓
Expected Net Value
    ↓
Remove Negative-Uplift / Negative-Value Candidates
    ↓
Rank Eligible Customers
    ↓
Apply Capacity
    ↓
Next-Best-Action Queue
```

The central distinction is:

> **The customer most likely to churn is not necessarily the customer for whom intervention creates the most value.**

---

# 📐 Decision Logic

| Layer                   | Question                         | Output                 |
| ----------------------- | -------------------------------- | ---------------------- |
| **Churn Model**         | Who may leave?                   | Churn probability      |
| **Treatment Model**     | Who may respond to intervention? | Estimated uplift       |
| **Value Layer**         | What value could be protected?   | Expected protected MRR |
| **Cost Layer**          | What does intervention cost?     | Action cost            |
| **Policy Engine**       | Should we intervene?             | Eligibility            |
| **Capacity Constraint** | Who should receive outreach?     | Ranked queue           |

This separation prevents churn probability from becoming the final business decision.

---

# 🖥️ Decision Intelligence Interface

The application exposes the decision process through account, policy and model-health views.

### Account-level analysis

Each scored account can expose:

* churn risk;
* treatment uplift;
* expected net value;
* reason codes;
* recommended action.

### Policy controls

The decision policy can be adjusted through:

* churn-risk threshold;
* outreach capacity.

The resulting targeting queue can then be inspected against the risk-only baseline.

### Model monitoring

The monitoring layer exposes:

* discrimination;
* calibration;
* segment quality;
* stability / drift metrics.

---

# 📊 Reproducibility

The default deterministic workflow uses:

| Property              | Configuration                 |
| --------------------- | ----------------------------- |
| Generated accounts    | **2,400**                     |
| Train / holdout split | **75 / 25**                   |
| Random seed           | **42**                        |
| Treatment assignment  | **Randomized**                |
| Holdout               | **Untouched during training** |
| Runtime artifacts     | Generated locally             |
| CI                    | Retrains from scratch         |

Runtime models, metrics, accounts and policies are generated into:

```text
data/runtime/
```

These runtime artifacts are intentionally not committed.

---

# 🧪 Real-World Randomized-Data Benchmark

RetainIQ includes a separate feasibility benchmark using the **64,000-row Hillstrom email experiment**.

The benchmark:

1. downloads the commit-pinned dataset;
2. validates its SHA-256 checksum;
3. validates the leakage-safe schema;
4. trains a treatment-effect model;
5. evaluates on a joint-stratified holdout;
6. applies a **20% outreach-capacity policy**;
7. produces JSON and Markdown evidence under `artifacts/real_data/`.

The targeting policy is evaluated using held-out evidence.

Promotion requires:

* held-out Qini;
* top-capacity uplift;
* IPW policy value.

A positive average treatment effect alone is **not sufficient** for promotion.

The target, split, reuse audit and promotion thresholds are frozen before the benchmark run in the real-data admission record.

---

# 🔬 Machine Learning Methodology

## Churn Prediction

RetainIQ uses a logistic classifier to estimate customer churn probability.

```mermaid
flowchart LR

    A["Customer Features"] --> B["Feature Processing"]
    B --> C["Logistic Regression"]
    C --> D["P(Churn)"]

    style A fill:#EFF6FF,stroke:#3B82F6,stroke-width:2px,color:#111827
    style B fill:#EEF2FF,stroke:#6366F1,stroke-width:2px,color:#111827
    style C fill:#ECFDF5,stroke:#10B981,stroke-width:2px,color:#111827
    style D fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px,color:#111827
```

---

## Treatment Effect Estimation

RetainIQ uses a **T-learner** to estimate treatment effects.

Separate outcome models are fitted for treatment and control conditions:

```mermaid
flowchart TD

    A["Customer Features"] --> B["Treatment Model"]
    A --> C["Control Model"]

    B --> D["Predicted Outcome<br/>Y(1)"]
    C --> E["Predicted Outcome<br/>Y(0)"]

    D --> F["Estimated Treatment Effect"]
    E --> F

    style A fill:#EFF6FF,stroke:#3B82F6,stroke-width:2px,color:#111827
    style B fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px,color:#111827
    style C fill:#E0F2FE,stroke:#0284C7,stroke-width:2px,color:#111827
    style D fill:#DCFCE7,stroke:#16A34A,stroke-width:2px,color:#111827
    style E fill:#DBEAFE,stroke:#2563EB,stroke-width:2px,color:#111827
    style F fill:#F3E8FF,stroke:#8B5CF6,stroke-width:3px,color:#111827
```

Conceptually:

```text
Estimated Treatment Effect
=
Y(1) − Y(0)
```

where:

* `Y(1)` = predicted outcome under treatment;
* `Y(0)` = predicted outcome under control.

---

# 💰 Value-Based Decisioning

The treatment effect becomes useful when connected to the economics of the intervention.

```mermaid
flowchart LR

    A["Estimated Uplift"] --> B["Protected MRR"]
    C["Customer MRR"] --> B

    B --> D["Expected Protected Value"]

    E["Action Cost"] --> F["Expected Net Value"]
    D --> F

    F --> G{"Positive?"}

    G -->|"Yes"| H["Eligible"]
    G -->|"No"| I["Exclude"]

    style A fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px,color:#111827
    style C fill:#E0F2FE,stroke:#0284C7,stroke-width:2px,color:#111827
    style B fill:#F3E8FF,stroke:#8B5CF6,stroke-width:2px,color:#111827
    style D fill:#EDE9FE,stroke:#7C3AED,stroke-width:2px,color:#111827
    style E fill:#FEE2E2,stroke:#EF4444,stroke-width:2px,color:#111827
    style F fill:#DBEAFE,stroke:#2563EB,stroke-width:3px,color:#111827
    style G fill:#FFF7ED,stroke:#EA580C,stroke-width:2px,color:#111827
    style H fill:#DCFCE7,stroke:#059669,stroke-width:2px,color:#111827
    style I fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#111827
```

This allows RetainIQ to prioritize interventions based on **expected incremental business value**, rather than churn probability alone.

---

# 🔌 API

RetainIQ exposes the decisioning workflow through a FastAPI service.

| Endpoint                 | Purpose                                                                      |
| ------------------------ | ---------------------------------------------------------------------------- |
| `GET /api/summary`       | Active policy, value-aware outcome, risk-only baseline and priority accounts |
| `GET /api/accounts`      | Scored holdout population                                                    |
| `GET /api/accounts/{id}` | Risk, uplift, net value, reasons and recommended play                        |
| `POST /api/score`        | Score a new account from current signals                                     |
| `GET /api/policy/curve`  | Compare value-aware and risk-only value across thresholds                    |
| `PUT /api/policy`        | Persist policy threshold and outreach capacity                               |
| `GET /api/monitoring`    | Held-out discrimination, calibration, segment and stability metrics          |

When running locally, interactive API documentation is available at:

```text
http://127.0.0.1:8000/docs
```

---

# 🏛️ Project Structure

```text
retain-iq/
│
├── signalroom/
│   ├── training.py
│   ├── real_benchmark.py
│   ├── main.py
│   └── ...
│
├── tests/
│   └── ...
│
├── docs/
│   ├── architecture.md
│   ├── model-card.md
│   └── REAL_DATA_ADMISSION.md
│
├── artifacts/
│   └── real_data/
│
├── .github/
├── .devcontainer/
├── Dockerfile
├── docker-compose.yml
├── pyproject.toml
├── render.yaml
├── app.js
└── README.md
```

> **Note:** The repository's Python package directory remains `signalroom/` unless you also rename the internal source package. Renaming the project branding to RetainIQ does not require changing the Python package name.

---

# 🐳 Run Locally

## Requirements

* Python **3.11+**
* Docker *(optional)*

## Python

Create a virtual environment:

```bash
python -m venv .venv
```

### Windows

```bash
.venv\Scripts\activate
```

### macOS / Linux

```bash
source .venv/bin/activate
```

Install development dependencies:

```bash
pip install -e ".[dev]"
```

Train the default workflow:

```bash
python -m signalroom.training
```

Start the API:

```bash
uvicorn signalroom.main:app --reload
```

Then open:

```text
http://127.0.0.1:8000
```

API documentation:

```text
http://127.0.0.1:8000/docs
```

---

## Docker

Run the application stack with:

```bash
docker compose up --build
```

---

# 🧪 Verification

The repository includes automated checks covering:

* deterministic data generation;
* randomized treatment assignment;
* value and capacity gates;
* risk-only comparison;
* account scoring;
* policy persistence;
* account detail;
* monitoring artifacts;
* API validation.

Run:

```bash
ruff check .
pytest --cov=signalroom --cov-fail-under=85
node --check app.js
docker compose config -q
```

---

# 🛡️ Engineering & Reproducibility

RetainIQ is designed as a reproducible ML application rather than a single notebook experiment.

Key engineering practices include:

* deterministic random seed;
* untouched holdout evaluation;
* treatment assignment controls;
* model card;
* reproducible training;
* Docker support;
* FastAPI serving;
* automated tests;
* linting;
* dependency management;
* CI retraining;
* checksum-pinned real-world benchmark;
* explicit promotion criteria.

---

# 💡 What RetainIQ Demonstrates

### Data Science

* Classification
* Treatment-effect estimation
* Uplift modeling
* Model calibration
* Policy evaluation
* Customer value modeling
* Holdout evaluation
* Experimentation concepts

### Decision Science

* Next-best-action decisioning
* Capacity-constrained targeting
* Value-based targeting
* Cost-aware intervention
* Risk vs incremental-impact analysis

### ML Engineering

* Python
* FastAPI
* Docker
* CI
* Automated testing
* Reproducible training
* API-based model serving
* Monitoring

---

# ⭐ Why RetainIQ Is Different

Most churn projects stop here:

```text
Customer Data
     ↓
Churn Model
     ↓
Churn Probability
     ↓
High-Risk Customers
```

RetainIQ goes further:

```text
Customer Data
     ↓
Churn Risk
     +
Treatment Effect
     +
Customer Value
     −
Action Cost
     ↓
Expected Net Value
     ↓
Capacity Constraint
     ↓
Next-Best Action
```

The core idea is simple:

> **Predicting who will churn is not the same as deciding who should receive an intervention.**

RetainIQ is designed around that distinction.

---

# 📚 Documentation

* [Architecture Notes](docs/architecture.md)
* [Model Card](docs/model-card.md)
* [Real Data Admission Record](docs/REAL_DATA_ADMISSION.md)
* [Contributing](CONTRIBUTING.md)
* [Security Policy](SECURITY.md)

---

# 📄 License

This project is licensed under the **MIT License**.

---

<div align="center">

### RetainIQ

**From churn prediction → treatment effect → business value → action.**

</div>
