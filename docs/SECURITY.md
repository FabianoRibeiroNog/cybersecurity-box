# Project Security Rules

## Secrets

Never commit:

- Wi-Fi passwords
- API keys
- tokens
- private keys
- credentials

Real secret files must remain outside version control.

## Network Monitoring

The ESP32 Network Monitor defaults to passive Wi-Fi observation.

Features that actively interfere with networks must not be introduced
without explicit authorization and a controlled lab scope.

## Git

Always inspect changes before committing:

git diff

and after staging:

git diff --staged
