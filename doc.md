# User Documentation for Pdfbox3.xqm XQuery Library

## Overview

The `Pdfbox3.xqm` library provides an interface to the Apache PDFBox 3.0 library for working with PDF documents in BaseX 10.7+. It allows you to perform various operations on PDF files, such as extracting text, rendering pages to images, extracting metadata, and more.
## Namespace

The library uses the namespace `org.expkg_zone58.Pdfbox3`.

```xquery
module namespace pdfbox="org.expkg_zone58.Pdfbox3";
```

## Functions

### `pdfbox:with-pdf($src as xs:string, $fn as function(item()) as item()*) as item()*`

This function opens a PDF file, applies a given function to it, and ensures the PDF is closed after use.

- **Parameters:**
  - `$src`: The path to the PDF file.
  - `$fn`: A function that takes a PDF object as input and returns some result.

- **Example:**
  ```xquery
  pdfbox:with-pdf("path/to/document.pdf", pdfbox:page-text(?, 5))
  ```

### `pdfbox:open-file($pdfpath as xs:string) as item()`

Opens a PDF file and returns a PDF object.

- **Parameters:**
  - `$pdfpath`: The path to the PDF file.

- **Example:**
  ```xquery
  let $pdf := pdfbox:open-file("path/to/document.pdf")
  return pdfbox:page-count($pdf)
  ```

### `pdfbox:specification($pdf as item()) as xs:string`

Returns the version of the PDF specification used by the document.

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:specification($pdf)
  ```

### `pdfbox:save($pdf as item(), $savepath as xs:string) as xs:string`

Saves the PDF object to the specified file path.

- **Parameters:**
  - `$pdf`: A PDF object.
  - `$savepath`: The path where the PDF should be saved.

- **Example:**
  ```xquery
  pdfbox:save($pdf, "path/to/save/document.pdf")
  ```

### `pdfbox:close($pdf as item()) as empty-sequence()`

Closes the PDF object, releasing resources.

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:close($pdf)
  ```

### `pdfbox:page-count($pdf as item()) as xs:integer`

Returns the number of pages in the PDF.

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:page-count($pdf)
  ```

### `pdfbox:page-image($pdf as item(), $pageNo as xs:integer, $options as map(*)) as xs:base64Binary`

Renders a specific page of the PDF as an image.

- **Parameters:**
  - `$pdf`: A PDF object.
  - `$pageNo`: The page number to render.
  - `$options`: A map of options, including `format` (e.g., "gif", "png") and `scale`.

- **Example:**
  ```xquery
  pdfbox:page-image($pdf, 1, map { "format": "png", "scale": 2 })
  ```

### `pdfbox:metadata($pdf as item()) as map(*)`

Returns a map containing metadata about the PDF.

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:metadata($pdf)
  ```

### `pdfbox:report($pdfpath as xs:string) as map(*)`

Returns a summary of the PDF, including metadata and page count.

- **Parameters:**
  - `$pdfpath`: The path to the PDF file.

- **Example:**
  ```xquery
  pdfbox:report("path/to/document.pdf")
  ```

### `pdfbox:hasOutline($pdf as item()) as xs:boolean`

Returns `true` if the PDF has an outline (bookmarks).

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:hasOutline($pdf)
  ```

### `pdfbox:isEncrypted($pdf as item()) as xs:boolean`

Returns `true` if the PDF is encrypted.

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:isEncrypted($pdf)
  ```

### `pdfbox:outline($pdf as item()) as map(*)*`

Returns the outline (bookmarks) of the PDF as a sequence of maps.

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:outline($pdf)
  ```

### `pdfbox:outline-xml($pdf as item()) as element(outline)?`

Returns the outline (bookmarks) of the PDF as XML.

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:outline-xml($pdf)
  ```

### `pdfbox:extract($pdf as item(), $start as xs:integer, $end as xs:integer, $target as xs:string) as xs:string`

Extracts a range of pages from the PDF and saves them as a new PDF.

- **Parameters:**
  - `$pdf`: A PDF object.
  - `$start`: The starting page number (1-based).
  - `$end`: The ending page number (1-based).
  - `$target`: The path to save the new PDF.

- **Example:**
  ```xquery
  pdfbox:extract($pdf, 1, 3, "path/to/new/document.pdf")
  ```

### `pdfbox:labels($pdf as item()) as xs:string*`

Returns the page labels for each page in the PDF.

- **Parameters:**
  - `$pdf`: A PDF object.

- **Example:**
  ```xquery
  pdfbox:labels($pdf)
  ```

### `pdfbox:page-text($doc as item(), $pageNo as xs:integer) as xs:string`

Returns the text content of a specific page in the PDF.

- **Parameters:**
  - `$doc`: A PDF object.
  - `$pageNo`: The page number to extract text from.

- **Example:**
  ```xquery
  pdfbox:page-text($pdf, 1)
  ```

### `pdfbox:version() as xs:string`

Returns the version of the Apache PDFBox library in use.

- **Example:**
  ```xquery
  pdfbox:version()
  ```

## Notes

- The library is designed to work with BaseX 10.7+.
- Some functions may throw errors if the PDF is encrypted or if the file cannot be opened.

## Examples

### Extracting Text from a PDF Page

```xquery
let $pdf := pdfbox:open-file("path/to/document.pdf")
return pdfbox:page-text($pdf, 1)
```

### Rendering a PDF Page as an Image

```xquery
let $pdf := pdfbox:open-file("path/to/document.pdf")
return pdfbox:page-image($pdf, 1, map { "format": "png", "scale": 2 })
```

### Extracting Metadata

```xquery
let $pdf := pdfbox:open-file("path/to/document.pdf")
return pdfbox:metadata($pdf)
```

### Extracting a Range of Pages

```xquery
let $pdf := pdfbox:open-file("path/to/document.pdf")
return pdfbox:extract($pdf, 1, 3, "path/to/new/document.pdf")
```
