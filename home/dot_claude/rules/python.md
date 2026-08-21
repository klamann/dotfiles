---
paths:
  - "**/*.py"
---

# Python Development Rules

- Docstrings: Use Sphinx/reST style (`:param:`, `:return:`, `:raises:`). Write data model documentation in triple-quoted docstrings (one per field).
- Pre-commit hooks: Run pre-commit hooks (lint, format, type check) after making code changes. Use `prek run` (preferred) or `pre-commit run` to execute hooks. Try to fix any discovered issues instead of adding exclusion rules or ignoring directives (# noqa, # type: ignore etc.)
- Tests: Write unit tests for new features and bug fixes. Call `pytest` with the right project manager, depending on the project (e.g. `uv run pytest` or `poetry run pytest`).
- Imports: Don't use relative imports (`from .a import b`). Don't use wildcard imports (`from a import *`). Only use local imports (within a function) when necessary to avoid circular dependencies.
- Logging: Write log messages that are concise and informative. Don't use `print` statements for debugging; use the logging system.
- Typing: Use type annotations on all function signatures. Don't write type hints in docstrings.
- Refactoring: Prefer to mimic the code structure and patterns used in the project instead of refactoring everything, unless explicitly instructed. Don't use this as excuse to repeat existing mistakes when adding new code though.
- Naming conventions: Don't use leading underscores for class names. Only use them for functions if they are never imported from another file.
- Functions and Methods: Prefer to use classmethods and staticmethods over standalone functions if they logically belong to a single class.
- Global variables: Don't create global variables for things that are only referenced in one or two places. Prefer to pack related information into a single data structure over creating multiple global variables with a shared prefix.
- Inline comments: Only write inline comments when the code cannot be made clear without them. Prefer to extract code that requires lots of commentary to a separate function or method with a docstring instead of using long inline comments.
