# Install Tasks

install-iOS:
	true

install-lint:
	brew remove swiftlint --force || true
	brew install swiftlint

# Run Tasks

test-iOS:
	set -o pipefail && \
		xcodebuild \
		-workspace Example/LyftSDK-Example.xcworkspace \
		-scheme LyftSDK_Example \
		-destination "name=iPhone 7" \
		test \
		| xcpretty -ct

test-lint:
	swiftlint lint --strict 2>/dev/null