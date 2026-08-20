# Terraform + Docker Web Server on AWS

A website hosted on AWS EC2, containerized with Docker, and
provisioned entirely with Terraform — no manual console clicking to
create the server.

## Architecture

```
   You (AWS CloudShell)
            |
            | terraform apply
            v
   Terraform  ->  creates:
            |
            +--> Security Group  (firewall: allow HTTP + SSH)
            |
            +--> EC2 Instance
                     |
                     | runs user_data.sh on first boot
                     v
                 Installs Docker
                     |
                     v
                 Builds image from Dockerfile
                     |
                     v
                 Runs container (Apache httpd serving index.html) on port 80
```

**Why each tool is here:**

| Tool | Role | Why it matters |
|---|---|---|
| **Terraform** | Infrastructure as Code — defines the security group and EC2 instance as text files instead of manual console clicks | Repeatable, version-controlled, reviewable infrastructure — the standard way cloud teams manage AWS resources |
| **Docker** | Packages the website (Apache httpd + your HTML) into a portable container image | The image runs identically anywhere — this EC2 instance, a different host, or any other cloud, with no "works on my machine" problems |
| **Git / GitHub** | Version control for all of the above | Lets you track changes, roll back, and show real infrastructure code in your portfolio |

**How it fits together:** Terraform doesn't install Docker itself —
it hands the EC2 instance a boot-time script (`user_data.sh`) that
installs Docker, builds the image, and starts the container
automatically the moment the server boots. This means the entire
stack — server + Docker + running website — comes up from a single
`terraform apply`, with zero manual SSH steps.

---

## Deployment — Step by Step (AWS CloudShell)

AWS CloudShell already has `git` and the AWS CLI installed. Terraform
is not pre-installed, so Step 1 installs it.

### Step 1 — Open CloudShell and install Terraform
1. AWS Console → CloudShell → run:
   ```bash
   curl -O https://releases.hashicorp.com/terraform/1.15.8/terraform_1.15.8_linux_amd64.zip
   unzip terraform_1.15.8_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   terraform -version
   ```

### Step 2 — AMI already configured
`variables.tf` is already set to the Amazon Linux 2023 (x86_64) AMI
for `ap-south-1`. If you ever redeploy in a different region, AMI IDs
are region-specific — look up the new one via **EC2 → AMI Catalog**
and update `variables.tf` accordingly.

### Step 3 — Get the project files into CloudShell
Easiest: create the GitHub repo first (Step 6 below), then in
CloudShell:
```bash
git clone https://github.com/YOUR-USERNAME/terraform-docker-project.git
cd terraform-docker-project
```
Or just create the four files directly in CloudShell using `cat >
filename` (paste content, then Ctrl+D) for each of `main.tf`,
`variables.tf`, `user_data.sh`.

### Step 4 — Deploy
```bash
terraform init      # downloads the AWS provider plugin
terraform plan       # shows exactly what will be created — review this
terraform apply       # type "yes" when prompted — creates real AWS resources
```
After a minute or two, Terraform prints the `public_ip` output.

### Step 5 — Verify
Wait ~60 seconds after apply finishes (Docker install + build takes a
moment), then either:
- Open `http://<public_ip>` in a browser, or
- From CloudShell: `curl http://<public_ip>`

You should see the "Deployed with Terraform + Docker" page.

### Step 6 — Push to GitHub
**Option 1 — GitHub web UI:**
1. github.com → **New repository** → `terraform-docker-project` → **Create**
2. **Add file → Create new file** for each of `main.tf`, `variables.tf`,
   `user_data.sh`, `.gitignore`, `README.md` → paste content → **Commit**

**Alternative — from CloudShell (git is pre-installed):**
```bash
git init
git add .
git commit -m "Terraform + Docker EC2 web server"
git remote add origin https://github.com/YOUR-USERNAME/terraform-docker-project.git
git branch -M main
git push -u origin main
# Username: your GitHub username
# Password: a GitHub Personal Access Token (Settings → Developer
# settings → Personal access tokens → generate one, scope: repo)
```

### Step 7 — Tear down (avoid ongoing charges)
When you're done demoing it:
```bash
terraform destroy
# type "yes" when prompted
```
This deletes the EC2 instance and security group Terraform created.
See the Free Tier note below on why destroying it when unused
matters more for some AWS accounts than others.

---

## Free Tier Notes
`t2.micro` is AWS's standard free-tier-eligible instance type, but
whether it's actually free depends on your **AWS account's creation
date** — this changed on July 15, 2025:
- **Accounts created before July 15, 2025**: 750 hours/month of
  `t2.micro` free for the first 12 months (enough to run one
  instance 24/7 at no cost).
- **Accounts created on or after July 15, 2025**: no per-service
  12-month EC2 allowance. Instead you get a one-time $200 credit
  usable over 6 months, then standard billing applies (~$8–9/month
  for `t2.micro` if left running continuously).

This is an AWS account-level policy, not something the Terraform
code controls. Either way, running `terraform destroy` right after
you're done testing keeps actual cost close to zero — a few minutes
or hours of a `t2.micro` costs a fraction of a cent even outside the
free tier.

## Notes
- `.gitignore` deliberately excludes `.terraform/` and `*.tfstate` —
  state files can contain resource details and should never be
  committed to a public repo.
- No Python, and no manual server setup — `user_data.sh` is plain
  bash, and Terraform's `.tf` files are declarative configuration
  (`key = value`), not a programming language.
- Test `terraform plan` before every `apply` — it shows exactly what
  will change, which is the standard safety habit for using Terraform
  on real infrastructure.
  
