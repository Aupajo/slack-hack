# Slack Hack 'n' Slash Command

A Slack slash command for encouraging your team not to leave their laptops unlocked and unattended.

## Setup

To set up your development environment, run:

    bin/setup

This will check and install missing dependencies (where appropriate) and create and migrate databases.

To start a local development server, run:

    bin/start

## Configuration

* `SLACK_VERIFICATION_TOKEN` (as given by Slack when setting up the slash command)
* `DATABASE_URL` such as `postgres://user:password@host/dbname`
