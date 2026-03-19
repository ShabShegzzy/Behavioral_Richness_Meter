# Behavioral Richness Meter

## Overview

The **Behavioral Richness Meter** is a smart contract designed to measure the diversity and non-monotony of user behavior in decentralized systems. It rewards users for performing varied actions while penalizing repetitive, monotonous behavior. This encourages richer and more dynamic participation patterns over time.

---

## Features

* Tracks diversity of user actions over a configurable window.
* Rewards users for non-repetitive, unique actions (`RICHNESS-REWARD`).
* Penalizes repetitive actions to discourage monotony (`MONOTONY-PENALTY`).
* Configurable diversity window (`DIVERSITY-WINDOW`) and maximum action types (`MAX-ACTION-TYPE`).
* Transparent on-chain storage of richness score and unique action counts.
* Read-only helper functions for monitoring user behavior.

---

## Error Codes

* `ERR-ACTION-REPEATED` – action is repeated within the diversity window.
* `ERR-INVALID-ACTION` – submitted action type exceeds allowed maximum.

---

## Data Storage

* `last-action-type` – last action type performed by each user.
* `last-action-block` – block height of the last recorded action.
* `unique-action-count` – number of unique actions within the diversity window.
* `richness-score` – cumulative behavioral richness score.

---

## Core Logic

1. Users submit an `action-type` via `record-behavior`.
2. The contract validates the action type against `MAX-ACTION-TYPE`.
3. Behavior is assessed based on the diversity window (`DIVERSITY-WINDOW`):

   * If the last action was outside the window, the diversity counter resets.
   * If the same action is repeated, a monotony penalty is applied.
   * If a new action is performed, the user receives a richness reward.
4. Scores and counts are updated on-chain for transparency and persistence.

---

## Read-Only Functions

* `get-richness-score(user)` – fetches the current behavioral richness score.
* `get-unique-count(user)` – fetches the number of unique actions in the diversity window.

---

## Benefits

* Promotes diverse and non-monotonous user activity.
* Provides measurable metrics for rewarding dynamic participation.
* Transparent and auditable scoring stored on-chain.
* Can be integrated with reputation, governance, or reward systems to incentivize richer user engagement.

---

## Configuration Parameters

* `MAX-ACTION-TYPE` – maximum allowed action type (default 10).
* `DIVERSITY-WINDOW` – time window for tracking unique actions (default ~2 weeks).
* `RICHNESS-REWARD` – score increment for new actions.
* `MONOTONY-PENALTY` – score decrement for repeated actions.

---

This contract is ideal for communities, DAOs, or gamified platforms where diverse participation is valued over repetitive activity.
