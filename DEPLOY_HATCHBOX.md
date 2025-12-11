# Fizzy Deployment Guide for Hatchbox.io

This guide walks you through deploying Fizzy to your Hatchbox.io cluster.

## Deployment Summary

**Configuration:**
- **Database:** SQLite (default)
- **Storage:** Local disk
- **Background Jobs:** Solid Queue in Puma (single process)
- **Email:** Resend SMTP
- **Domain:** fizzy.iachetti.com
- **Ruby Version:** 3.4.7
- **Access Control:** ALLOW_SIGNUPS environment variable (enabled initially, then disabled after account creation)

---

## Prerequisites

- ✅ Hatchbox.io account with existing cluster and Hetzner server
- ✅ Git repository pushed to GitHub/GitLab/Bitbucket
- ⚠️ Resend account with SMTP credentials (see Step 1)
- ⚠️ DNS record for fizzy.iachetti.com pointing to your server

---

## Step 1: Set Up Resend SMTP

1. Sign up at https://resend.com (free tier: 3,000 emails/month)
2. Go to **API Keys** section
3. Create a new API key
4. **Important:** Resend uses your API key as the SMTP password
   - **SMTP Username:** `resend`
   - **SMTP Password:** Your API key (starts with `re_...`)
5. Add and verify your domain `iachetti.com` in Resend:
   - Go to **Domains** → **Add Domain**
   - Add the DNS records Resend provides (SPF, DKIM, DMARC)
   - Wait for verification (usually a few minutes)

**Save these values - you'll need them in Step 3!**

---

## Step 2: Configure DNS

Add a DNS A record for your domain:

```
Type: A
Name: fizzy
Value: [Your Hetzner server IP]
TTL: 300 (or auto)
```

Result: `fizzy.iachetti.com` → Your server IP

You can verify it's working with:
```bash
dig fizzy.iachetti.com
```

---

## Step 3: Create Application in Hatchbox

1. Log into your Hatchbox account at https://app.hatchbox.io
2. Select your existing cluster
3. Click **Apps** → **New App**
4. Configure the application:

### Basic Settings:
- **Name:** `fizzy`
- **Git Repository:** Your forked Fizzy repository URL
  - Example: `https://github.com/yourusername/fizzy.git`
- **Git Branch:** `main` (or your deployment branch)
- **Ruby Version:** Hatchbox will read `.ruby-version` automatically (3.4.7)

### Server Selection:
- Select your Hetzner server
- **Roles to enable:**
  - ✅ **Web** (serves the application)
  - ✅ **Cron** (runs database migrations automatically on deploy)

---

## Step 4: Configure Environment Variables

In Hatchbox, go to your app → **Environment** tab and add these variables:

### Required Secrets:
```bash
SECRET_KEY_BASE=46ef160ed195e21a1219f7b70be4cb167b8e660d24bd1aaeed123e756fbf7b6153757275bcdad4bf837e0d68fe6178d0aaf90abaa8b8d6d6ca2b5e8d39f4f22d

VAPID_PRIVATE_KEY=D_bGv0TXU7eMNgY957m9SzNRLJ1_VwSpKrrrSPvVr3A=

VAPID_PUBLIC_KEY=BP46cki5nKnLCVjzWeAZoPp0r4Rit6pBeVccQNNxUHVTp9uIO8jv7dIn9zvKcQQHRm-KYcawB3hoPI85hy64SmQ=
```

### Email Configuration:
```bash
SMTP_USERNAME=resend

SMTP_PASSWORD=re_your_api_key_here

MAILER_FROM_ADDRESS=noreply@iachetti.com
```
**Note:** Replace `re_your_api_key_here` with your actual Resend API key from Step 1.

### Application Configuration:
```bash
RAILS_ENV=production

RAILS_LOG_TO_STDOUT=true

SOLID_QUEUE_IN_PUMA=true

ALLOW_SIGNUPS=true

RUBY_YJIT_ENABLE=1
```

**Important:** We're setting `ALLOW_SIGNUPS=true` initially so you can create your account. We'll disable it after.

---

## Step 5: Configure Domain and SSL

In Hatchbox, go to your app → **Domains** tab:

1. Click **Add Domain**
2. Enter: `fizzy.iachetti.com`
3. Enable **SSL** (Hatchbox uses Caddy with automatic Let's Encrypt certificates)

Hatchbox will automatically:
- Configure Caddy to serve your app
- Request and install SSL certificate
- Set up automatic HTTPS redirect

---

## Step 6: Deploy!

1. In Hatchbox, go to your app page
2. Click the **Deploy** button
3. Monitor the deployment in the **Logs** tab

Hatchbox will:
- ✅ Clone your repository
- ✅ Install Ruby 3.4.7
- ✅ Run `bundle install`
- ✅ Precompile assets
- ✅ Run database migrations (because Cron role is enabled)
- ✅ Start Puma with Solid Queue
- ✅ Configure SSL certificate

**Deployment typically takes 3-5 minutes.**

---

## Step 7: Create Your Account

Once deployment completes:

1. Visit https://fizzy.iachetti.com
2. You should see the Fizzy landing/signup page
3. Click **Sign Up**
4. Enter your email address (e.g., `you@iachetti.com`)
5. Check your email for the magic link
6. Click the magic link to authenticate
7. Complete your account setup:
   - Enter your full name
   - Your account will be created with you as owner

---

## Step 8: Disable Public Signups

Now that you have your account, prevent others from signing up:

1. In Hatchbox, go to your app → **Environment** tab
2. Find the `ALLOW_SIGNUPS` variable
3. Change it from `true` to `false`:
   ```bash
   ALLOW_SIGNUPS=false
   ```
4. Click **Save**
5. **Redeploy** your app (click Deploy button)

Now if anyone tries to visit `/signup`, they'll see:
> "Signups are currently disabled. Please contact the administrator for an invitation."

---

## Step 9: Invite Others (Optional)

To invite people to your Fizzy account:

1. Log into Fizzy
2. Go to your account settings (click your avatar → **Account Settings**)
3. Navigate to **Join Code** section
4. Generate a join code (looks like `AbCd-EfGh-IjKl`)
5. Set the usage limit (how many times it can be used)
6. Share the join link with invitees:
   ```
   https://fizzy.iachetti.com/join/AbCd-EfGh-IjKl
   ```
7. They'll enter their email, get a magic link, and join your account

---

## Verification Checklist

After deployment, verify everything works:

- [ ] Can access https://fizzy.iachetti.com (redirects to HTTPS)
- [ ] SSL certificate is valid (green padlock in browser)
- [ ] Can log in with your account
- [ ] Can create a board
- [ ] Can create cards on the board
- [ ] Can upload images/attachments (local storage)
- [ ] Email magic links arrive quickly
- [ ] `/signup` route shows "disabled" message (after Step 8)
- [ ] Join codes work for inviting others

---

## Troubleshooting

### Issue: Magic link emails not arriving

**Check:**
1. Verify Resend domain is verified (DNS records set up)
2. Check Hatchbox app logs for email errors
3. Verify `SMTP_USERNAME=resend` and `SMTP_PASSWORD` are correct
4. Check spam/junk folder

**Solution:**
- In Resend dashboard, check **Emails** tab for delivery status
- Look for bounce/error messages

### Issue: "ActiveSupport::MessageEncryptor::InvalidMessage"

**Cause:** Missing or incorrect `SECRET_KEY_BASE`

**Solution:**
1. Generate new secret: `bin/rails secret`
2. Update `SECRET_KEY_BASE` in Hatchbox environment variables
3. Redeploy

### Issue: SSL certificate not provisioning

**Cause:** DNS not propagated or port 80/443 blocked

**Solution:**
1. Verify DNS with `dig fizzy.iachetti.com`
2. Check Hatchbox server firewall allows ports 80 and 443
3. Wait a few minutes and click **Retry SSL** in Hatchbox

### Issue: Database migration errors

**Cause:** Server doesn't have Cron role enabled

**Solution:**
1. In Hatchbox, go to **Servers** tab
2. Edit your server
3. Ensure **Cron** checkbox is enabled
4. Redeploy

### Issue: Background jobs not running

**Cause:** `SOLID_QUEUE_IN_PUMA` not set

**Solution:**
1. Verify environment variable is set: `SOLID_QUEUE_IN_PUMA=true`
2. Check Hatchbox logs for Solid Queue startup messages
3. Redeploy if needed

### Issue: 500 error or app not loading

**Check Logs:**
1. In Hatchbox: **Apps** → fizzy → **Logs**
2. Look for Ruby/Rails errors
3. Common issues:
   - Missing environment variables
   - Database connection issues
   - Asset compilation failures

---

## Useful Hatchbox Features

### View Logs
**Apps** → fizzy → **Logs** → Live tail or search

### Rails Console Access
1. SSH into server (Hatchbox provides SSH command in server details)
2. Navigate to app: `cd /home/deploy/fizzy/current`
3. Open console: `bin/rails console`

### Manual Deploy
**Apps** → fizzy → **Deploy** button

### Restart App
**Apps** → fizzy → **Restart** button (restarts Puma without full deploy)

### Database Backups
Since you're using SQLite, set up a backup script:
1. Go to **Scripts** in Hatchbox
2. Create a script to backup `storage/production.sqlite3`
3. Schedule it to run daily

Example backup script:
```bash
cd /home/deploy/fizzy/shared
tar -czf backup-$(date +%Y%m%d).tar.gz storage/
```

---

## Monitoring Background Jobs

Fizzy includes **Mission Control Jobs** for monitoring Solid Queue:

1. Visit: https://fizzy.iachetti.com/admin/jobs
2. You may need to configure authentication - check app/controllers/admin for details

This shows:
- Queued jobs
- Running jobs
- Failed jobs
- Recurring tasks (entropy, notifications, etc.)

---

## Changing Configuration Later

### Change Domain Name
1. Add new domain in Hatchbox → Domains
2. Update `production.rb` with new domain in `action_mailer.default_url_options`
3. Update `MAILER_FROM_ADDRESS` if needed
4. Commit and redeploy
5. Remove old domain from Hatchbox

### Change Email Provider
1. Get new SMTP credentials
2. Update `SMTP_USERNAME` and `SMTP_PASSWORD` in Hatchbox
3. Update `config/environments/production.rb` with new SMTP server/port
4. Commit and redeploy

### Switch to MySQL
1. In Hatchbox, create a MySQL database
2. Add environment variables:
   ```bash
   DATABASE_ADAPTER=mysql
   MYSQL_HOST=127.0.0.1
   MYSQL_PORT=3306
   MYSQL_USER=fizzy
   MYSQL_PASSWORD=your_db_password
   ```
3. Redeploy (migrations will run automatically)

### Enable Signups Again
Simply change `ALLOW_SIGNUPS=false` to `ALLOW_SIGNUPS=true` and redeploy.

---

## Cost Estimation

**Monthly costs:**
- Hatchbox: $10/server (shared with your other apps)
- Hetzner Server: Already paid (shared)
- Resend: $0 (free tier: 3,000 emails/month)

**Total additional cost: $0** (since you're using existing server)

---

## Code Changes Made

This deployment includes the following modifications to the original Fizzy code:

1. **`app/controllers/signups_controller.rb`**
   - Added `ALLOW_SIGNUPS` environment variable check
   - Displays message when signups are disabled
   - Defaults to `true` if not set (maintains backward compatibility)

2. **`config/environments/production.rb`**
   - Configured SMTP settings for Resend
   - Added `action_mailer.default_url_options` for fizzy.iachetti.com
   - Uncommented and updated email configuration

3. **`.ruby-version`**
   - Updated to 3.4.7 (from 3.4.2)

All changes are committed and ready to deploy!

---

## Support Resources

- **Hatchbox Documentation:** https://hatchbox.relationkit.io
- **Resend Documentation:** https://resend.com/docs
- **Fizzy Issues:** https://github.com/basecamp/fizzy/issues
- **Your Installation:** https://fizzy.iachetti.com

---

## Security Recommendations

1. **Keep ALLOW_SIGNUPS=false** in production
2. **Rotate secrets periodically:**
   - Generate new `SECRET_KEY_BASE` every 6-12 months
   - Generate new VAPID keys if needed
3. **Monitor failed login attempts** in logs
4. **Limit join code usage:** Set reasonable usage limits (e.g., 5-10 uses)
5. **Regenerate join codes** after major invitations to prevent link sharing
6. **Keep Fizzy updated:** Regularly pull updates from upstream repository
7. **Backup your SQLite database** regularly (set up automated backups)

---

## Next Steps After Deployment

1. ✅ Create your account
2. ✅ Disable signups (`ALLOW_SIGNUPS=false`)
3. ⚠️ Set up your first board
4. ⚠️ Customize account settings (name, entropy settings)
5. ⚠️ Generate join code for team members
6. ⚠️ Set up automated database backups
7. ⚠️ Test push notifications (if using them)
8. ⚠️ Configure user roles and board access

---

## Questions or Issues?

If you encounter any problems during deployment:

1. Check the **Troubleshooting** section above
2. Review Hatchbox logs for error messages
3. Verify all environment variables are set correctly
4. Check that DNS is properly configured
5. Ensure Resend domain is verified

Good luck with your deployment! 🚀
