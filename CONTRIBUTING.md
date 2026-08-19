Contributing Guide

Thank you for your interest in contributing to Azure Linux Storage Engineering.

This repository is primarily a hands-on Linux storage and Azure infrastructure learning project. Contributions that improve technical accuracy, documentation quality, lab reliability, automation, troubleshooting coverage, or production practices are welcome.

🎯 Contribution Goals

Contributions should help improve one or more of the following:

Linux storage knowledge
Azure storage practices
Hands-on lab quality
Shell automation
Troubleshooting
Monitoring
Backup and recovery
Production storage design
Documentation
Architecture diagrams
Interview preparation
🗂️ Repository Areas

Before contributing, understand the main repository structure:

azure-linux-storage-engineering/
│
├── docs/          # Technical documentation
├── labs/          # Hands-on implementation labs
├── scripts/       # Shell automation
├── screenshots/   # Lab evidence
├── diagrams/      # Architecture diagrams
├── cheatsheets/   # Quick references
├── assets/        # Project assets
└── .github/       # GitHub templates/workflows
🌿 Branching Strategy

Use a dedicated feature branch for changes.

Recommended naming:

feature/<description>

Examples:

feature/improve-storage-docs
feature/add-disk-monitoring
feature/improve-backup-script
feature/add-production-lab

For bug fixes:

fix/<description>

Example:

fix/fstab-validation
🔄 Recommended Workflow
1. Clone the repository
git clone <repository-url>
cd azure-linux-storage-engineering
2. Update the base branch
git checkout develop
git pull origin develop
3. Create a feature branch
git checkout -b feature/<your-change>
4. Make the changes

Keep changes focused and related to the purpose of the branch.

For example:

Documentation change
       ↓
docs/

Lab change
       ↓
labs/

Automation change
       ↓
scripts/

Evidence
       ↓
screenshots/
📝 Documentation Guidelines

Documentation should be:

Clear
Practical
Technically accurate
Easy to reproduce
Structured logically
Focused on real-world scenarios

Whenever possible, explain:

What
 ↓
Why
 ↓
How
 ↓
Validation
 ↓
Troubleshooting
 ↓
Production Considerations

Avoid documenting commands without explaining their purpose.

🧪 Lab Guidelines

Each lab should ideally contain:

README.md

The lab documentation should explain:

Objective
Prerequisites
Environment
Architecture
Implementation
Commands
Expected output
Validation
Troubleshooting
Cleanup
Production considerations
🖥️ Screenshot Guidelines

Screenshots should provide meaningful evidence of successful implementation.

Good screenshot examples:

Disk identification
Filesystem creation
Mount validation
fstab validation
LVM configuration
Service health
Backup validation
Restore validation
Monitoring output
Automation result

Avoid adding unnecessary screenshots that do not prove a specific step.

Use descriptive filenames.

Example:

disk-identity.png
filesystem-created.png
mount-validation.png
backup-success.png
restore-validation.png
⚙️ Shell Script Guidelines

Shell scripts should prioritize safety and reliability.

Where appropriate, scripts should include:

#!/usr/bin/env bash

Use strict error handling when suitable:

set -euo pipefail

Scripts should:

Validate inputs
Check required commands
Check expected files/directories
Verify mountpoints
Handle failures
Return meaningful exit codes
Avoid destructive operations without validation
Produce useful logs
Be safe to execute repeatedly where possible
🛡️ Storage Safety

Storage operations can be destructive.

Contributors must carefully validate:

lsblk
blkid
findmnt
df -hT

before performing operations involving:

Partitioning
Filesystem creation
Mounting
LVM
Disk resizing
Data migration
Cleanup

Never assume that /dev/nvme0n2, /dev/sdb, or another device name refers to a specific disk without verification.

🧹 Cleanup Scripts

Cleanup functionality must be conservative.

Before deleting data, scripts should verify:

Target path
Mountpoint
Expected filesystem
Required environment
User confirmation where appropriate

A cleanup script must never blindly delete arbitrary paths.

🔐 Sensitive Information

Never commit:

Passwords
API keys
Access tokens
SSH private keys
Azure credentials
Database credentials
Connection strings
Personal access tokens
Production secrets

Use placeholders instead.

Example:

<AZURE_SUBSCRIPTION_ID>
<RESOURCE_GROUP>
<MYSQL_PASSWORD>
📋 Commit Message Guidelines

Use clear and descriptive commit messages.

Recommended format:

<type>: <description>

Examples:

docs: improve storage fundamentals guide
lab: add mysql storage validation
feat: add storage monitoring script
fix: correct fstab validation
refactor: improve backup script error handling

Common types:

Type	Purpose
feat	New functionality
fix	Bug fix
docs	Documentation
lab	Lab changes
refactor	Code restructuring
test	Testing
chore	Maintenance
🔍 Before Opening a Pull Request

Run appropriate validations.

For shell scripts:

bash -n scripts/*.sh

If ShellCheck is available:

shellcheck scripts/*.sh

For Git status:

git status

Review the actual changes:

git diff

Make sure unnecessary files are not included.

🚀 Pull Request Process

Create a Pull Request after pushing your feature branch.

Example:

git push -u origin feature/<your-change>

The Pull Request should clearly explain:

What changed?

Describe the implementation.

Why was it changed?

Explain the problem or learning objective.

What was tested?

Mention commands, lab validation, or screenshots.

Evidence

Reference relevant screenshots or lab results.

📌 Pull Request Checklist

Before submitting:

Changes are focused and relevant

Documentation is updated

Lab README is updated if required

Scripts are syntax-checked

Destructive operations were tested safely

Screenshots are included where useful

No secrets are committed

No unnecessary files are included

Commit messages are descriptive

Git diff has been reviewed

Pull Request description is complete

🐛 Reporting Issues

Use the GitHub issue template when reporting problems.

Include:

Lab/day
Environment
Linux distribution
Command executed
Error message
Expected result
Actual result
Relevant screenshot
Troubleshooting already attempted

Example:

Lab: Day 06 - fstab

Environment:
Ubuntu Linux VM

Problem:
mount -a fails

Expected:
Filesystem should mount successfully.

Actual:
mount reports an invalid fstab entry.

Evidence:
screenshots/lab06/...
💡 Suggesting Improvements

Useful improvement proposals include:

New storage labs
Better troubleshooting scenarios
Safer automation
Monitoring improvements
Azure integration
Production architecture improvements
New diagrams
Better cheatsheets
Additional interview questions

Suggestions should explain the practical value of the change.

🤝 Contribution Philosophy

The purpose of this project is not simply to collect commands.

A useful contribution should improve the ability to understand:

Infrastructure
     ↓
Storage
     ↓
Application
     ↓
Monitoring
     ↓
Automation
     ↓
Recovery

Contributions that make the project more practical, reproducible, safe, and production-oriented are especially valuable.

📄 License

By contributing to this repository, contributors agree that their contributions will be provided under the project's existing license.

See:

LICENSE

for details.

🙌 Thank You

Thank you for helping improve the Azure Linux Storage Engineering project.

Every improvement — whether a documentation correction, lab enhancement, automation improvement, troubleshooting scenario, or production recommendation — helps make the project more useful for real-world infrastructure learning.