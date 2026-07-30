# Module 12: Capstone Project

Runnable artifacts for this module. Lesson prose lives on
[devoriales.com](https://devoriales.com). This folder holds only what you run.

| # | Lesson | Artifacts |
| --- | --- | --- |
| 1 | Build a GitOps repo structure from scratch (app-of-apps + ApplicationSets) | `01-repo-structure/` |

`01-repo-structure/root-application.yaml` is the only file you apply by hand. It points at
`apps/`, which holds an AppProject in sync wave `-1` and the Applications that reference it
in wave `0`, so the project always exists before anything needs it. Adding an environment
is adding one file to `apps/`.
| 2 | Deploy a multi-environment app (DEV to STAGING to PROD) with progressive sync | `02-*/` |
| 3 | Add signed-commit enforcement and an ApplicationSet-driven tenant model | `03-*/` |
| 4 | Wire up notifications and a basic Grafana dashboard | `04-*/` |

Folders appear here as each lesson is published and verified. A lesson folder
contains only what the course has taught up to that point.
