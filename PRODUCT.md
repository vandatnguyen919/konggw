# Kong Gateway Playground

## Purpose

Teach Java and Spring developers how a bank-style Kong topology separates a
centrally governed, database-backed control plane from regional DB-less data
planes. Teams own API configuration in Git and publish it through decK and CI.

## First useful result

Running `docker compose up --build` starts PostgreSQL, one Kong control plane,
two Kong data planes, and the products and orders services. The Admin API and
Kong Manager are bound to localhost only. A learner can publish the platform
and team files, provision a consumer at runtime, and send authenticated
requests through both data planes.

## Decisions

- Use Kong Gateway free mode `kong/kong-gateway:3.11.0.0`, pinned and without a
  license file. Kong Manager and hybrid mode are available; enterprise RBAC,
  SSO, and multiple workspaces are not assumed.
- Use PostgreSQL only on the control plane. Data planes use in-memory config
  received over mTLS.
- Generate a shared hybrid-mode certificate pair on first Compose startup in
  `certs/`; never commit it.
- Use `owner:platform` and `team:<name>` tags as the governance boundary.
- Pin PostgreSQL 16.4 and decK 1.68.0 (published image tag `v1.68.0`).
- Keep the existing Spring Boot 4 services and Java 27 toolchain.

## Current state

The hybrid topology, team manifests, policy checks, decK targets, runtime
consumer demo, outage demo, CI workflow, and smoke-test entry point are
implemented and Docker-verified. The Kong Manager page review remains
judgment pending.

## Non-goals

Real NAB infrastructure, cloud or Kubernetes deployment, Konnect,
production-wide TLS, SSO/RBAC, multiple workspaces, custom Lua, and a custom
UI. OpenTelemetry and Prometheus remain a separate stretch feature.
