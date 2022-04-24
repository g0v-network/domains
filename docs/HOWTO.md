# How To

This section is a work in progress.

- [DNS Records](#dns-records)
- [Subdomains](#subdomains)
- [Email Forwarders](#email-forwarders)
- [Domains](#domains)
- [Redirects](#redirects)

## DNS Records

Our setup on Cloudflare supports the follow record types: ([octoDNS docs][])

    A, AAAA, ALIAS, CAA, CNAME, MX, NS, PTR, SPF, SRV, TXT

You'll mostly wish to use these common types:
- `A`: most common and basic (ipv4)
- `AAAA`: same as `A`, but for ipv6
- `CNAME`: domain name aliases. only works on _subdomains_. often used in custom domains for hosted services like GitHub Pages, Heroku, etc.
- `ALIAS`: similar to `CNAME`, but works only on _root domain_
- `MX`: used to setting up email addresses
- `TXT`: holds arbitrary text data

Both `A` and `CNAME` records can be proxied with Cloudflare, if specified as below.
This is most convenient for `domain.com` and `sub.domain.com`, but for second-level subdomains like `2nd.sub.domain.com`, you're likely to hit issues.
([Cloudflare docs][]. [General docs][2nd-level-subdomain].)

   [Cloudflare docs]: https://support.cloudflare.com/hc/en-us/articles/200169626-What-subdomains-are-appropriate-for-orange-gray-clouds-
   [2nd-level-subdomain]: https://serverfault.com/questions/104160/wildcard-ssl-certificate-for-second-level-subdomain

See the examples below to support in managing records.

(Note that either `value` or `values` can be used as key, but the latter expects an array.)

### Examples

<details>
  <summary>Adding an MX record to existing [sub]domain</summary>

```diff
diff --git a/g0v.ca.domain/g0v.ca.yaml b/g0v.ca.domain/g0v.ca.yaml
index 3050a90..474481e 100644
--- a/g0v.ca./g0v.ca.yaml
+++ b/g0v.ca./g0v.ca.yaml
@@ -15,3 +15,7 @@
       - 301 https://g0v.tw/intl/en/
   - type: ALIAS
     value: 301.ronny.tw.
+  - type: MX
+    values:
+      - exchange: mx.example.com.
+        preference: 10
```

</details>

<details>
  <summary>Add one more TXT record</summary>

```diff
diff --git a/g0v.ca.domain/g0v.ca.yaml b/g0v.ca.domain/g0v.ca.yaml
index 3050a90..2a62d42 100644
--- a/g0v.ca./g0v.ca.yaml
+++ b/g0v.ca./g0v.ca.yaml
@@ -6,6 +6,7 @@
       - admin=patcon
       # Used for 301 redirect service below
       - 301 https://g0v.tw/intl/en/
+      - google-site-verification=1234-abcd-5678-EFGH
   - type: ALIAS
     value: 301.ronny.tw.
```

</details>

<details>
  <summary>Create root domain <a href="#redirects">redirect</a>: <code>g0v.network</code> to <code>example.com</code></summary>

```diff
diff --git a/g0v.network.domain/g0v.network.yaml b/g0v.network.domain/g0v.network.yaml
index aca1501..8049f5d 100644
--- a/g0v.network./g0v.network.yaml
+++ b/g0v.network./g0v.network.yaml
@@ -42,3 +42,9 @@
         preference: 10
       - exchange: mx2.forwardemail.net.
         preference: 10
+  - type: TXT
+    values:
+      # Used for 301 redirect service below
+      - 301 https://example.com/
+  - type: ALIAS
+    value: 301.ronny.tw.
```

</details>

<details>
  <summary>Create subdomain <a href="#redirects">redirect</a>: <code>mysubdomain.g0v.ca</code> to <code>example.com</code></summary>

```diff
diff --git a/config.yaml b/config.yaml
index 3d10aed..4947530 100644
--- a/config.yaml
+++ b/config.yaml
@@ -21,6 +21,8 @@ zones:
     targets:
       - cloudflare
   g0v.ca.:
     sources:
       - config-files
     targets:
diff --git a/g0v.ca.domain/mysubdomain.g0v.ca.yaml b/g0v.ca.domain/mysubdomain.g0v.ca.yaml
new file mode 100644
index 0000000..7536024
--- /dev/null
+++ b/g0v.ca./mysubdomain.g0v.ca.yaml
@@ -0,0 +1,8 @@
+---
+mysubdomain:
+  - type: TXT
+    values:
+      # Used for 301 redirect service below
+      - 301 https://example.com/
+  - type: A
+    # 301.ronny.tw
+    value: 52.69.187.52
```

</details>


<details>
  <summary>Create <code>mysubdomain.g0v.ca</code> and point to IP</summary>

```diff
diff --git a/g0v.ca.domain/mysubdomain.g0v.ca.yaml b/g0v.ca.domain/mysubdomain.g0v.ca.yaml
new file mode 100644
index 0000000..d079979
--- /dev/null
+++ b/g0v.ca./mysubdomain.g0v.ca.yaml
@@ -0,0 +1,11 @@
+---
+mysubdomain:
+  - type: A
+    octodns:
+      cloudflare:
+        proxied: true
+    value: 123.45.67.89
+    metdata:
+      repository: https://github.com/your-user/your-repo
+      maintainer:
+        - some-username
```

</details>

<details>
  <summary>Delete subdomain <code>oldapp.g0v.network</code></summary>

```diff
diff --git a/g0v.network.domain/oldapp.g0v.network.yaml b/g0v.network.domain/oldapp.g0v.network.yaml
deleted file mode 100644
index ed900a2..0000000
--- a/g0v.network./oldapp.g0v.network.yaml
+++ /dev/null
@@ -1,11 +0,0 @@
----
-oldapp:
-  type: CNAME
-  value: my-old-app.netlify.com.
-  metadata:
-    repo: https://github.com/g0v-network/my-old-app
-    maintainer:
-      - some-username
```

</details>

[octoDNS docs]: https://github.com/octodns/octodns#supported-providers

## Subdomains

To add a new subdomain, just add an `A` or `CNAME` record as above, but for a
new subdomain using a new config file.

## Email Forwarders

- #todo describe forwardemail service
- https://forwardemail.net/en/faq#table-dns-management-by-registrar
- really just adding a specific type of DNS Record (see above)
- example: adding a new email to existing subdomain
  - for new subdomain, see above

### Add a New Forwarder

#todo

## Domains

### Add a New Domain

If you'd like to start managing a new domain through this repo, you can do
that! You'll only need to point your registrar at our Cloudflare nameservers --
you keep the domain with your registrar, and the domain itself stays in your
hands.

1. Create a new domain directory and config (see below)
2. Copy your existing records into appropriate yaml config.
3. Submit a pull request.
4. We'll create a new zone for your domain in the Cloudflare admin interface.
5. We'll add that zone to our existing Cloudflare API token, so it can be managed by our automation.
6. We'll merge the pull request after review
    - Cloudflare's nameserver will be updated on merge, but your registrar won't be pointed to it yet.
7. After merging, point your registrar at our Cloudflare nameservers:
    ```
    clyde.ns.cloudflare.com
    tina.ns.cloudflare.com
    ```
8. Confirm that your DNS records work as expected, using:
    - DNS Nameserver Checker: https://mxtoolbox.com/SuperTool.aspx?action=dns:g0v.ca&run=toolpage

### Examples

<details>
  <summary>Adding <code>example.com</code> as newly managed domain</summary>

```diff
diff --git a/README.md b/README.md
index b079994..8266139 100644
--- a/README.md
+++ b/README.md
@@ -7,6 +7,7 @@ The following damains can be managed here:
 - `g0v.ca`
 - `c4nada.ca`
 - `t0ronto.ca`
+- `example.com`
 
 Changing or adding DNS records in `main` branch of this repository will update
 the actual domain records.
diff --git a/config.yaml b/config.yaml
index 3d10aed..c23c490 100644
--- a/config.yaml
+++ b/config.yaml
@@ -35,3 +35,8 @@ zones:
       - config-files
     targets:
       - cloudflare
+  example.com.:
+    sources:
+      - config-files
+    targets:
+      - cloudflare
diff --git a/example.com.domain/example.com.yaml b/example.com.domain/example.com.yaml
new file mode 100644
index 0000000..acedadd
--- /dev/null
+++ b/example.com.domain/example.com.yaml
@@ -0,0 +1,6 @@
+---
+'':
+  - type: TXT
+    values:
+      # Who has admin for this domain
+      - admin=<some identifier of person who owns it>
```

</details>

## Redirects

This section describes how we support redirects, e.g. having `g0v.ca` redirect to `https://g0v.tw/intl/en/`.

Some DNS providers offer helpers to provide url redirects without hosting a special app.
This is sometimes done through non-compliant pseudo-records ([like DNSimple does][redirect-dnsimple]),
or through a separate platform feature ([like Cloudflare does][redirect-cloudflare]).

   [redirect-dnsimple]: https://github.com/octodns/octodns/issues/505
   [redirect-cloudflare]: https://support.cloudflare.com/hc/en-us/articles/200172286-Configuring-URL-forwarding-or-redirects-with-Cloudflare-Page-Rules

To help allow redirects to be created in this repo in a consistent way,
we instead opt to use a g0v-hosted tool called [`ronnywang/301-service`][301-service].
It's hosted at [`301.ronny.tw`][301-ronny] ([translated into English][301-ronny-en]).

   [301-service]: https://github.com/ronnywang/301-service
   [301-ronny]: https://301.ronny.tw/
   [301-ronny-en]: https://translate.google.com/translate?hl=&sl=auto&tl=en&u=https://301.ronny.tw

For specific examples of how to add redirects, see [DNS Records](#dns-records) examples above.

Once you've added a redirect like this, then the non-SSL link will work fine.

E.g., http://g0v.ca can redirect to https://g0v.tw/intl/en/

But note that HTTPS https://g0v.ca won't redirect cleanly without a browser warning.
This is due to how all HTTPS security certificates work, and how this 301-service app works with these certificates.

But there's good news! If you'd like HTTPS redirects to also work,
@ronnywang is [willing to add][] your redirect origin domain to his certificate.

E.g., if you wished `https://sub.example.com` to cleanly redirect to http://g0v.tw,
you would ask @ronnywang to **add `sub.example.com` to his certificate**.
Even without submitting this additional request, `http://sub.example.com` (without SSL) would still redirect fine.

**[Click here][https-request] to submit a request.**

   [willing to add]: https://github.com/ronnywang/301-service/issues/2#issuecomment-791874487
   [https-request]: https://github.com/ronnywang/301-service/issues/new?title=Add%20SUB.EXAMPLE.COM%20as%20alt%20domain%20on%20HTTPS%20certificate&body=Re-ticketed%20from%20%5Bthese%20docs%5D(https%3A%2F%2Fgithub.com%2Fg0v-network%2Fdomains%2Fblob%2Fmain%2Fdocs%2FHOWTO.md%23redirects).%0A%0APlease%20add%20SUB.EXAMPLE.COM%20as%20a%20%22Subject%20Alternative%20Name%22%20to%20the%20301.ronny.tw%20HTTPS%20certificate.%20Thanks!
