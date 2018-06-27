$(document).ready(function () {
    $("button").click(function () {
        var query = $('input, select').serialize();
        $.getJSON("https://htwn231l78.execute-api.us-east-1.amazonaws.com/ajax_test/get?" + query, function (result) {
            $.each(result, function (i, json) {
                // EXTRACT VALUE FOR HTML HEADER. 
                var col = [];
                for (var i = 0; i < json.length; i++) {
                    for (var key in json[i]) {
                        if (col.indexOf(key) === -1) {
                            col.push(key);
                        }
                    }
                }

                // CREATE DYNAMIC TABLE.
                var table = document.createElement("table");

                // CREATE HTML TABLE HEADER ROW USING THE EXTRACTED HEADERS ABOVE.

                var tr = table.insertRow(-1);                   // TABLE ROW.

                for (var i = 0; i < col.length; i++) {
                    var th = document.createElement("th");      // TABLE HEADER.
                    th.innerHTML = col[i];
                    tr.appendChild(th);
                }

                // ADD JSON DATA TO THE TABLE AS ROWS.
                for (var i = 0; i < json.length; i++) {

                    tr = table.insertRow(-1);

                    for (var j = 0; j < col.length; j++) {
                        var tabCell = tr.insertCell(-1);
                        tabCell.innerHTML = json[i][col[j]];
                    }
                }

                // FINALLY ADD THE NEWLY CREATED TABLE WITH JSON DATA TO A CONTAINER.
                var divContainer = document.getElementById("showData");
                divContainer.append(table);

            });
        });
    });
});