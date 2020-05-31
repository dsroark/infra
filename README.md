A place where my infrastructure code lives.  Currently I am using Terraform in tandem with ansible.  It may be more feasible in the future to split these out but while they remain my pet projects it is easier for me to put the code here
.

# Terraform

all terraform code lives in the `terraform` directory.  Each subdirectory is to
be considered an individual state, and I currently use workspaces to separate
out environments.

# Ansible

All ansible cod is in the `ansible` directory.  more details tbd

# Contributing

Feel free to fork, use what you need for your own infrastructure, and ideally
submit a pull request back into this PR if something can be improved.  This repo
is single trunk and just use `master` as the base branch.
