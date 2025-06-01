// simple javascript support

//https://www.w3schools.com/howto/howto_js_treeview.asp
var toggler = document.getElementsByClassName("caret");
var i;

for (i = 0; i < toggler.length; i++) {
  toggler[i].addEventListener("click", function () {
    this.parentElement.querySelector(".nested").classList.toggle("active");
    this.classList.toggle("caret-down");
  });
}
// table sort https://stackoverflow.com/questions/10683712/html-table-sort#10683805
document.querySelectorAll('th').forEach((element) => { // Table headers
  element.addEventListener('click', function () {
    let table = this.closest('table');

    // If the column is sortable
    if (this.querySelector('span')) {
      let order_icon = this.querySelector('span');
      let order = encodeURI(order_icon.innerHTML).includes('%E2%86%91') ? 'desc' : 'asc';
      let separator = '-----'; // Separate the value of it's index, so data keeps intact

      let value_list = {}; // <tr> Object
      let obj_key = []; // Values of selected column

      let string_count = 0;
      let number_count = 0;

      // <tbody> rows
      table.querySelectorAll('tbody tr').forEach((line, index_line) => {
        // Value of each field
        let key = line.children[element.cellIndex].textContent.toUpperCase();

        // Check if value is date, numeric or string
        if (line.children[element.cellIndex].hasAttribute('data-timestamp')) {
          // if value is date, we store it's timestamp, so we can sort like a number
          key = line.children[element.cellIndex].getAttribute('data-timestamp');
        }
        else if (key.replace('-', '').match(/^[0-9,.]*$/g)) {
          number_count++;
        }
        else {
          string_count++;
        }

        value_list[key + separator + index_line] = line.outerHTML.replace(/(\t)|(\n)/g, ''); // Adding <tr> to object
        obj_key.push(key + separator + index_line);
      });
      if (string_count === 0) { // If all values are numeric
        obj_key.sort(function (a, b) {
          return a.split(separator)[0] - b.split(separator)[0];
        });
      }
      else {
        obj_key.sort();
      }

      if (order === 'desc') {
        obj_key.reverse();
        order_icon.innerHTML = '&darr;';
      }
      else {
        order_icon.innerHTML = '&uarr;';
      }

      let html = '';
      obj_key.forEach(function (chave) {
        html += value_list[chave];
      });
      table.getElementsByTagName('tbody')[0].innerHTML = html;
    }
  });
});
