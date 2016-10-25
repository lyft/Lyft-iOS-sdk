# Install Tasks

install-lint:
	brew remove swiftlint --force || true
	brew install swiftlint

# Run Tasks

test-lint:
	swiftlint lint --strict 2>/dev/null