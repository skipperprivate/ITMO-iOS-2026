#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
task_test_dir=$(mktemp -d /private/tmp/MiniTwitterNetwork.XXXXXX)

xcrun swiftc -parse-as-library -swift-version 6 -module-name Lab3 \
  -default-isolation MainActor Tests/LegacyStore.swift -o "$task_test_dir/legacy"

xcrun swiftc -parse-as-library -swift-version 6 -module-name MiniTwitter -default-isolation MainActor \
  -enable-upcoming-feature NonisolatedNonsendingByDefault \
  MiniTwitter/Models/Tweet.swift MiniTwitter/Models/TweetDTO.swift MiniTwitter/Models/TwitterAPIModels.swift \
  MiniTwitter/Services/MockTweetsAPI.swift MiniTwitter/Services/TwitterAPIClient.swift \
  MiniTwitter/Services/TweetCacheRepository.swift MiniTwitter/Services/BackgroundModelExecutor.swift \
  MiniTwitter/Services/TweetRepositoryProvider.swift MiniTwitter/ViewModels/TweetsViewModel.swift \
  Tests/NetworkStubs.swift Tests/ConcurrencyChecks.swift -o "$task_test_dir/checks"

"$task_test_dir/legacy" "$task_test_dir"
"$task_test_dir/checks" prepare "$task_test_dir"
"$task_test_dir/checks" reopen "$task_test_dir"
"$task_test_dir/checks" verify-delete "$task_test_dir"
if [[ "${1:-}" == "--live" ]]; then
  "$task_test_dir/checks" live
fi
printf 'Проверки завершены. Временная база: %s\n' "$task_test_dir"
