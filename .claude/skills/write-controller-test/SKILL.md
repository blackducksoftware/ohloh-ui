---
name: write-controller-test
description: Write Minitest controller tests for a given controller in ohloh-ui. Use when asked to add, write, or generate tests for a Rails controller.
argument-hint: "<controller-name>  (e.g. projects or projects_controller)"
disable-model-invocation: true
allowed-tools: Read Bash(find *) Bash(ls *)
---

## Context

Arguments received: $ARGUMENTS

```!
# Normalise the name: strip _controller suffix if present, then add it back
RAW=$(echo "$ARGUMENTS" | sed 's/_controller$//')
CTRL="${RAW}_controller"
TEST_FILE="test/controllers/${CTRL}_test.rb"
SRC_FILE="app/controllers/${CTRL}.rb"

echo "=== CONTROLLER SOURCE: $SRC_FILE ==="
if [ -f "$SRC_FILE" ]; then
  cat "$SRC_FILE"
else
  echo "(file not found)"
fi

echo ""
echo "=== EXISTING TEST FILE: $TEST_FILE ==="
if [ -f "$TEST_FILE" ]; then
  cat "$TEST_FILE"
else
  echo "(no existing test file — will create one)"
fi
```

## Instructions

Using the controller source and existing tests above, write comprehensive Minitest tests for the `$ARGUMENTS` controller.

### Rules — follow these exactly

1. **File**: write to `test/controllers/<controller>_test.rb` (create if missing, append if exists)
2. **Class**: `class <Controller>Test < ActionController::TestCase`
3. **Factories**: use `create(:factory)` — check `test/factories/` if unsure of factory names
4. **Auth**: use `login_as <account>` for authenticated requests, `login_as nil` for guest
5. **Structure**: group tests by action with a `# action_name` comment before each group
6. **Style**:
   - `let(:thing) { create(:thing) }` for shared setup
   - `it 'description' do ... end` for each test
   - `get/post/patch/delete :action, params: { ... }` for requests
   - `assert_response :ok / :redirect / :unauthorized / :not_found`
   - `assert_redirected_to path` for redirects
   - `assert_select 'css-selector'` for view assertions
   - `_(value).must_equal expected` for value assertions
7. **Coverage per action**:
   - Happy path (logged in, valid params)
   - Guest/unauthenticated access (expect redirect or 401)
   - Invalid/missing params (expect error response or redirect)
   - Authorization — actions that should be restricted to owners/admins
8. **Do not** add `require 'test_helper'` if the file already has it
9. **Do not** duplicate tests that already exist in the file
