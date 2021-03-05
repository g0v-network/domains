# How To

This section is a work in progress.

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

Both `A` and `CNAME` records can be proxied with Cloudflare, if specified as below. ([Cloudflare docs][])

   [Cloudflare docs]: https://support.cloudflare.com/hc/en-us/articles/200169626-What-subdomains-are-appropriate-for-orange-gray-clouds-

See the examples below to support in managing records.

(Note that either `value` or `values` can be used as key, but the latter expects an array.)

### Examples

<details>
  <summary>Adding an MX record to existing [sub]domain</summary>

```diff
diff --git a/g0v.ca./g0v.ca.yaml b/g0v.ca./g0v.ca.yaml
index 3050a90..474481e 100644
--- a/g0v.ca./g0v.ca.yaml
+++ b/g0v.ca./g0v.ca.yaml
@@ -15,3 +15,7 @@
       - 301 https://g0v.tw/
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
diff --git a/g0v.ca./g0v.ca.yaml b/g0v.ca./g0v.ca.yaml
index 3050a90..2a62d42 100644
--- a/g0v.ca./g0v.ca.yaml
+++ b/g0v.ca./g0v.ca.yaml
@@ -6,6 +6,7 @@
       - admin=patcon
       # Used for 301 redirect service below
       - 301 https://g0v.tw/
+      - google-site-verification=1234-abcd-5678-EFGH
   - type: ALIAS
     value: 301.ronny.tw.
```

</details>

<details>
  <summary>Create root domain redirect: <code>g0v.network</code> to <code>example.com</code></summary>

```diff
diff --git a/g0v.network./g0v.network.yaml b/g0v.network./g0v.network.yaml
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
  <summary>Create subdomain redirect: <code>mysubdomain.g0v.ca</code> to <code>example.com</code></summary>

```diff
diff --git a/config.yaml b/config.yaml
index 3d10aed..4947530 100644
--- a/config.yaml
+++ b/config.yaml
@@ -21,6 +21,8 @@ zones:
     targets:
       - cloudflare
   g0v.ca.:
+    # Allow TXT and CNAME to be created on same subdomain.
+    lenient: true
     sources:
       - config-files
     targets:
diff --git a/g0v.ca./mysubdomain.g0v.ca.yaml b/g0v.ca./mysubdomain.g0v.ca.yaml
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
+  - type: CNAME
+    value: 301.ronny.tw.
```

</details>


<details>
  <summary>Create <code>mysubdomain.g0v.ca</code> and point to IP</summary>

```diff
diff --git a/g0v.ca./mysubdomain.g0v.ca.yaml b/g0v.ca./mysubdomain.g0v.ca.yaml
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
diff --git a/g0v.network./oldapp.g0v.network.yaml b/g0v.network./oldapp.g0v.network.yaml
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
diff --git a/example.com./example.com.yaml b/example.com./example.com.yaml
new file mode 100644
index 0000000..acedadd
--- /dev/null
+++ b/example.com./example.com.yaml
@@ -0,0 +1,6 @@
+---
+'':
+  - type: TXT
+    values:
+      # Who has admin for this domain
+      - admin=<some identifier of person who owns it>
```

</details>
