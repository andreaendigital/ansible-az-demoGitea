## Description
Brief description of changes made in this PR.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Azure Environment Impact
- [ ] Changes affect Azure VM configuration
- [ ] Changes affect MySQL Flexible Server connection
- [ ] Changes affect Gitea application settings
- [ ] Changes affect systemd services

## Testing
- [ ] Ansible playbook runs successfully on Azure VMs
- [ ] Gitea service starts and responds correctly
- [ ] MySQL connection is established properly
- [ ] Load balancer health checks pass
- [ ] No breaking changes to existing functionality

## Checklist
- [ ] Code follows Ansible best practices
- [ ] Tasks are idempotent
- [ ] Variables are properly defined in group_vars
- [ ] Secrets are managed via Ansible Vault or environment variables
- [ ] Documentation has been updated
- [ ] Changes have been tested locally with molecule/vagrant (if applicable)
- [ ] Commit messages use DEMO-22 prefix for Jira integration

## Related Issues
Closes # (issue number)

## Additional Notes
Any additional information about the PR.
