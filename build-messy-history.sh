#!/bin/bash
# build-messy-history.sh
#
# Run this ONCE, from inside your local clone of relay-race, AFTER you've
# copied the site files in but BEFORE you've made any commits beyond the
# repo's existing "initial commit" (README.md).
#
# What it does: creates a spread-out, believable commit history with junk
# commits, dead-end files, and one real leak (archive/wyvern/config.old)
# that gets committed and then "panic-reverted" a few commits later. The
# leak stays fully recoverable via `git log -p` / GitHub's file history —
# that recoverability IS the puzzle. Nothing here squashes or rewrites,
# so nothing you push is ever destroyed.
#
# EDIT THE TWO VARIABLES BELOW BEFORE RUNNING.

REAL_DOMAIN="irc.YOURDOMAIN.tld"          # <-- fill in once you've picked it
REAL_CHANNEL="#collective"                 # <-- fill in the real channel, if relevant

set -e

commit() {
  # commit "YYYY-MM-DDTHH:MM:SS" "message"
  GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1" git commit -m "$2"
}

# ---- decoy commit 1: junk todo file, nothing to do with the puzzle ----
echo "- fix css spacing on mobile at some point" > TODO.txt
git add TODO.txt
commit "2024-02-11T14:22:00" "wip"

# ---- decoy commit 2: an abandoned backup folder, never cleaned up ----
mkdir -p old_backup_donotdelete
echo "unused, keeping just in case" > old_backup_donotdelete/scratch.txt
git add old_backup_donotdelete
commit "2024-02-14T09:03:00" "backup stuff, dont touch"

# ---- real scaffolding, spread across several small commits ----
git add index.html assets/
commit "2024-03-02T20:11:00" "site skeleton"

git add robots.txt
commit "2024-03-02T20:44:00" "robots.txt"

git add archive/council archive/subject-06767 archive/daily-affirmations
commit "2024-03-05T11:02:00" "add archive folders"

git add sitemap.xml
commit "2024-03-06T22:57:00" "sitemap"

# ---- THE LEAK ----
# wyvern's page goes in as normal, but config.old goes in WITH the real
# content this time — this is the moment a player is digging for.
git add archive/wyvern/index.html
cat > archive/wyvern/config.old <<EOF
# old client config, do not redistribute
server = ${REAL_DOMAIN}
port = 6697
channel = ${REAL_CHANNEL}
EOF
git add archive/wyvern/config.old
commit "2024-03-09T01:40:00" "add wyvern notes"

# ---- decoy commits AFTER the leak, to bury it under normal-looking activity ----
GIT_AUTHOR_DATE="2024-03-11T16:20:00" GIT_COMMITTER_DATE="2024-03-11T16:20:00" \
  git commit --allow-empty -m "typo fix"

echo "- maybe rename archive/ to data/ later" >> TODO.txt
git add TODO.txt
commit "2024-03-15T13:05:00" "update todo"

echo "unused" > old_backup_donotdelete/scratch2.txt
git add old_backup_donotdelete
commit "2024-03-20T19:12:00" "more backup junk"

# ---- humans.txt, added later, totally unrelated timing to the leak ----
git add humans.txt
commit "2024-04-02T10:30:00" "add humans.txt"

# ---- more filler, different "voice" to sell multiple contributors/moods ----
GIT_AUTHOR_DATE="2024-04-19T23:58:00" GIT_COMMITTER_DATE="2024-04-19T23:58:00" \
  git commit --allow-empty -m "asdf"

GIT_AUTHOR_DATE="2024-05-01T08:14:00" GIT_COMMITTER_DATE="2024-05-01T08:14:00" \
  git commit --allow-empty -m "merge fix??"

# ---- THE PANIC REVERT ----
# config.old gets deleted. This is the commit message that's the actual
# breadcrumb — it tells a careful reader something is worth digging for,
# without saying what.
git rm archive/wyvern/config.old
commit "2024-05-03T02:11:00" "oh shit accidentally uploaded config.old, hope i dont get fired lmao"

# ---- a couple more decoys AFTER the panic revert, so it's not the ----
# ---- most recent commit either — buries it from both directions ----
GIT_AUTHOR_DATE="2024-05-10T17:40:00" GIT_COMMITTER_DATE="2024-05-10T17:40:00" \
  git commit --allow-empty -m "cleanup"

echo "nothing to see here" >> old_backup_donotdelete/scratch.txt
git add old_backup_donotdelete
commit "2024-05-14T12:00:00" "ugh"

echo "Done. Review with: git log --oneline --all"
echo "Verify the leak is recoverable with: git log -p -- archive/wyvern/config.old"
echo "When happy, push with: git push origin main"
