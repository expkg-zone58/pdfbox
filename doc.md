# User Guide for Pdfbox3.xqm Library (XAR Distribution)

## Introduction

The `Pdfbox3.xqm` library is an XQuery module designed to interface with **Apache PDFBox 3.0**, a powerful Java library for working with PDF documents. This module allows you to perform various operations on PDF files, such as extracting text, rendering pages as images, managing outlines, and more. The library is distributed as a **XAR (XQuery Archive) file**, which includes the necessary PDFBox JAR files, making it easy to install and use in BaseX 10.7+.

---

## Installation

### 1. Download the XAR File
The library is distributed as a XAR file that includes the required PDFBox JAR files. You can obtain the XAR file from the distribution source (e.g., a repository or a shared location).

### 2. Install the XAR File in BaseX
To install the XAR file in BaseX, follow these steps:

1. Open the BaseX GUI or command-line interface.
2. Use the `REPO INSTALL` command to install the XAR file:

   ```xquery
   REPO INSTALL path/to/pdfbox3.xar
   ```

   Replace `path/to/pdfbox3.xar` with the actual path to the XAR file.

3. Verify the installation by listing the installed packages:

   ```xquery
   REPO LIST
   ```

   You should see `pdfbox3` listed among the installed packages.

---

## Basic Usage

### Importing the Module
Once the XAR file is installed, you can import the module in your XQuery scripts:

```xquery
import module namespace pdfbox="org.expkg_zone58.Pdfbox3";
```

---

### Opening a PDF Document
To open a PDF document, use the `pdfbox:open` function. This function can handle local files, URLs, or binary data. 

```xquery
let $pdf := pdfbox:open("path/to/document.pdf")
```

---

### Closing a PDF Document
Always close the PDF document after use to release resources.

```xquery
pdfbox:close($pdf)
```

---

### Extracting Text from a Page
To extract text from a specific page, use the `pdfbox:page-text` function.

```xquery
let $text := pdfbox:page-text($pdf, 1)  (: Extract text from page 1 :)
```

---

### Rendering a Page as an Image
You can render a PDF page as an image using the `pdfbox:page-render` function. Supported formats include `jpg`, `png`, `bmp`, and `gif`.

```xquery
let $image := pdfbox:page-render($pdf, 1, map{"format": "png", "scale": 2})
```

- `format`: The image format (default is `jpg`).
- `scale`: The scaling factor (default is `1`, which corresponds to 72 DPI).

---

### Extracting a Range of Pages
To extract a range of pages from a PDF, use the `pdfbox:extract-range` function.

```xquery
let $extracted := pdfbox:extract-range($pdf, 1, 3)  (: Extract pages 1 to 3 :)
```

The result is a new PDF document in binary format.

---

### Getting Document Properties
You can retrieve various properties of a PDF document, such as the title, author, and creation date.

```xquery
let $title := pdfbox:property($pdf, "title")
let $author := pdfbox:property($pdf, "author")
```

Supported properties include:
- `#bookmarks` :Number of bookmarks
- `#labels` :Number of labels
- `#pages` : Number of pages
- `author`: Document author.
- `creationDate`: Document creation date.
- `creator`: Document creator.
- `keywords`: Document keywords.
- `labels`: Document  labels formated as a string.
 `modificationDate`: Document modification date.
- `producer`: Document producer.
- `specification` PDF spec version used in the document.
- `subject`: Document subject.
- `title`: Document title.

---

### Working with Outlines (Bookmarks)
To retrieve the outline (bookmarks) of a PDF, use the `pdfbox:outline` function.

```xquery
let $outline := pdfbox:outline($pdf)
```

The outline is returned as a sequence of maps, where each map represents a bookmark with properties like `title`, `index`, and `hasChildren`.

---

### Saving a PDF Document
To save a PDF document to the filesystem, use the `pdfbox:pdf-save` function.

```xquery
let $savedPath := pdfbox:pdf-save($pdf, "path/to/save/document.pdf")
```

---



---

### Getting Page Labels
To retrieve page labels (if they exist), use the `pdfbox:labels` function.

```xquery
let $labels := pdfbox:labels($pdf)
```

---

### Getting Page Size
To get the size of a specific page, use the `pdfbox:page-media-box` function.

```xquery
let $size := pdfbox:page-media-box($pdf, 1)  (: Get size of page 0, the cover :)
```

---

### Generating a Report
You can generate a CSV-style report of properties for multiple PDFs using the `pdfbox:report` function.

```xquery
let $report := pdfbox:report(("path/to/doc1.pdf", "path/to/doc2.pdf"))
```

The report includes all properties by default, such as `title`, `author`, `#pages` , etc., for each PDF. 

---
## Advanced Usage

### Handling Encrypted PDFs
If the PDF is encrypted, you can provide a password when opening the document.

```xquery
let $pdf := pdfbox:open("path/to/encrypted.pdf", map{"password": "your_password"})
```
## Error Handling
The library includes error handling to manage issues such as failed PDF loads or unsupported operations. Errors are thrown with descriptive messages to help diagnose problems.

```xquery
try {
    let $pdf := pdfbox:open("invalid/path.pdf")
    return pdfbox:page-text($pdf, 1)
} catch * {
    fn:error($err:code, $err:description)
}
```

---
