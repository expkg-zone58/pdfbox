# 0.4.0 2025-06-04
* ADD Label access
* various renames
* Doc updates
# 0.3.6 2025-05-31
* Add metadata function
* rename page-size->page-media-box
# 0.3.1 2025-05-28
* update to Apache pdfbox to 3.0.5
* API name changes e.g. page-count->number-of-pages
# 0.2.7 2025-02-18
* reduce memory use
* add open from xs:base64Binary
* open opts with password
* increase test coverage
## 0.2.5 2025-02-17
* rename property pages to pageCount
* increase test coverage
## 0.2.4 2025-02-16
* Add `property`
* rewrite `report` to return CSV style data
* replace `open-file` with `open` using `fetch:binary` to allow urls
* Mod `extract` returns xs:base64Binary
* password support
## 0.1.6 2025-02-14
* Add `hasLabels`
* FIX #1 error if no labels
## 0.1.5 2025-02-10
* Add `isEncrypted`
* Rename `open` to `open-file`