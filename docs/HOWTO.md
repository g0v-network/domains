# How To

This section is a work in progress.

## DNS Records

- #todo share types that work here
- #todo example: adding new record to existing subdomain

## Subdomains

- #todo example: new subdomain

<details>
  <summary>Sample File Changes</summary>

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

## Email Forwarders

- #todo describe forwardemail service
- https://forwardemail.net/en/faq#table-dns-management-by-registrar
- really just adding a specific type of DNS Record (see above)
- example: adding a new email to existing subdomain
  - for new subdomain, see above

### Add a New Forwarder

#todo

## Domains

- Point nameservers to Cloudflare #todo
- #todo can octodns create new zonefile automatically?
- DNS Nameserver Checker: https://mxtoolbox.com/SuperTool.aspx?action=dns:g0v.ca&run=toolpage

### Add a New Domain

#todo
