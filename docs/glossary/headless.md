# Headless

How a runner runs when it has no display access: Mac Runner removes display
settings from the job's environment and sets `CI` and `HEADLESS`. On macOS it
does not stop a job from opening windows. See
[display access](../features/gui-access.md).
